#!/bin/sh

startup() {
    echo Starting Tomcat Server    
    ${CATALINA_HOME}/bin/startup.sh
    # Waiting 30 Seconds for App to Startup
    sleep 30
    # This is only valid for inital setup
    echo "Fortify Init Token"
    cat ${FORTIFY_HOME}/ssc/init.token
    tail -n +1 -F ${CATALINA_HOME}/logs/*.log ${FORTIFY_HOME}/ssc/logs/*.log
}

shutdown() {
    echo Stopping Tomcat Server
    ${CATALINA_HOME}/bin/shutdown.sh
}

trap "shutdown" INT
startup