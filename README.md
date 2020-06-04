# Fortify Software Security Center
# Version 20.01

### Build Instructions
1. Download the Fortify installer and place ssc.war in the build directory.
2. Execute `docker build -t fortify-scc:latest .` from the build directory.

### Docker Instructions
1. Download a JDBC Driver for one of the supported databases. The SQL Server Driver is already provided.
2. Create the appropriate schema or database and run the sql scripts from the Fortify installer. 
3. In our example we are using a local install of MySQL so we'll have to make some configuration changes to my.cnf make Fortify happy.
    ```
    [mysqld]
    max_allowed_packet=1G
    character-set-server=utf8
    collation-server=utf8_bin
    sql_mode=TRADITIONAL
    ```
4. Start Docker
    ```shell
    docker run -it --rm \
        -p 8080:8080 \
        -v fortifyVolume:/opt/fortify \
        -v $PWD/mysql-connector-java-5.1.49.jar:/usr/local/tomcat/lib/mysql-connector-java.jar \
        --name fortify \
        fortify-scc:latest
    ```
5. Goto http://localhost:8080/ssc/init.jsp
6. Copy and paste license file into wizard, check the box and click next.
7. Set Fortify SCC URL to http://localhost:8080/ssc and click next.
8. Assuming your using Docker Desktop set the url for MySQL to this and specify the username and password.
    ```
    jdbc:mysql://host.docker.internal/fortify
    ```
9. Seed the Database with the Process and Report Seed Bundles from the Fortify installer.
10. Restart Docker Container

## Docker Compose
You will need to make the following changes to use the include Docker Compose Example
1. Your MySQL host will be ```db``` instead of ```host.docker.internal```
2. Place ```sql/``` folder from Fortify Installer in your current directory.
    ```
    docker-compose up
    ```

## Volumes
1. Fortify Home is ```/opt/fortify``` and is the only volume configured. Configuration and indexes are stored here by default.

## SSL
1. To enable ssl you will need a Java KeyStore and TrustStore. Here is an example.
    ```shell
    docker run -it --rm \
        -p 8443:8443 \
        -e FORTIFY_SSL_ENABLE=true \
        -e FORTIFY_SSL_KEYSTORE=/usr/local/tomcat/conf/keystore.jks \
        -e FORTIFY_SSL_KEYSTORE_PASSWORD=changeit \
        -e FORTIFY_SSL_TRUSTSTORE=/usr/local/tomcat/conf/truststore.jks \
        -e FORTIFY_SSL_TRUSTSTORE_PASSWORD=changeit \
        -v fortifyVolume:/opt/fortify \
        -v $PWD/mysql-connector-java-5.1.49.jar:/usr/local/tomcat/lib/mysql-connector-java.jar \
        -v $PWD/keystore.jks:/usr/local/tomcat/conf/keystore.jks \
        -v $PWD/truststore.jks:/usr/local/tomcat/conf/truststore.jks \
        --name fortify \
        fortify-scc:latest
    ```

## Other
1. CATALINA_OPTS - Java Opts for Tomcat like -Xmx and -Xms