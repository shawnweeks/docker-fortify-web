#!/bin/bash
set -e

configure() {
    # SSL Configuration
    # FORTIFY_SSL_ENABLE
    # FORTIFY_SSL_KEYSTORE
    # FORTIFY_SSL_KEYSTORE_PASSWORD
    # FORTIFY_SSL_TRUSTSTORE
    # FORTIFY_SSL_TRUSTSTORE_PASSWORD
    # FORTIFY_SSL_CLIENT_AUTH - Optional Default is false
    # FORTIFY_SSL_PORT - Optional Default is 8443

    if [[ -n ${FORTIFY_SSL_ENABLE} ]]
    then
        echo "SSL Enabled - Setting Parameters"
        if [[ -z ${FORTIFY_SSL_KEYSTORE} || -z ${FORTIFY_SSL_KEYSTORE_PASSWORD} || -z ${FORTIFY_SSL_TRUSTSTORE} || -z ${FORTIFY_SSL_TRUSTSTORE_PASSWORD} ]]
        then
            echo "These variables are required if FORTIFY_SSL_ENABLE is true"
            echo "FORTIFY_SSL_KEYSTORE"
            echo "FORTIFY_SSL_KEYSTORE_PASSWORD"
            echo "FORTIFY_SSL_TRUSTSTORE"
            echo "FORTIFY_SSL_TRUSTSTORE_PASSWORD"
            exit 1
        fi
        echo "Disabling HTTP and Enabling HTTPS"
        xmlstarlet ed --inplace \
            -d '/Server/Service/Connector[@port="8080"]' \
            -s '/Server/Service' -t elem -n "Connector" \
            -i '$prev' -t attr -n "protocol" -v "org.apache.coyote.http11.Http11NioProtocol" \
            -i '$prev/..' -t attr -n "port" -v "${FORTIFY_SSL_PORT:-8443}" \
            -i '$prev/..' -t attr -n "maxThreads" -v "200" \
            -i '$prev/..' -t attr -n "scheme" -v "https" \
            -i '$prev/..' -t attr -n "SSLEnabled" -v "true" \
            -i '$prev/..' -t attr -n "keystoreFile" -v "${FORTIFY_SSL_KEYSTORE}" \
            -i '$prev/..' -t attr -n "keystorePass" -v "${FORTIFY_SSL_KEYSTORE_PASSWORD}" \
            -i '$prev/..' -t attr -n "truststoreFile" -v "${FORTIFY_SSL_TRUSTSTORE}" \
            -i '$prev/..' -t attr -n "truststorePassword" -v "${FORTIFY_SSL_TRUSTSTORE_PASSWORD}" \
            -i '$prev/..' -t attr -n "clientAuth" -v "false" \
            -i '$prev/..' -t attr -n "sslProtocol" -v "TLS" \
            ${CATALINA_HOME}/conf/server.xml
    fi
}

startup() {
    echo Starting Tomcat Server    
    ${CATALINA_HOME}/bin/startup.sh
    sleep 15
    echo 'Fortify SSC Init Token'
    echo $(cat ${FORTIFY_HOME}/ssc/init.token)
    tail -n +1 -F ${CATALINA_HOME}/logs/*.log ${FORTIFY_HOME}/ssc/logs/*.log
}

shutdown() {
    echo Stopping Tomcat Server
    ${CATALINA_HOME}/bin/shutdown.sh
}

trap "shutdown" INT
configure
startup