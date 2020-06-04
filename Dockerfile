FROM  tomcat:9-jdk8-openjdk-slim

ENV FORTIFY_USER fortify
ENV FORTIFY_GROUP fortify
ENV FORTIFY_HOME /opt/fortify
ENV UID 1001
ENV GID 1001

RUN apt-get update && \
    apt-get install xmlstarlet -y && \
    groupadd -r -g 1001 ${FORTIFY_USER} && \
    useradd -r -u 1001 -g ${FORTIFY_GROUP} -m -d ${FORTIFY_HOME} ${FORTIFY_USER} && \
    chown ${FORTIFY_USER}:${FORTIFY_GROUP} -R ${CATALINA_HOME}

COPY --chown=${FORTIFY_USER}:${FORTIFY_GROUP} ssc.war ${CATALINA_HOME}/webapps
COPY entrypoint.sh /bin/

RUN chmod 755 /bin/entrypoint.sh

USER ${FORTIFY_USER}
WORKDIR ${FORTIFY_HOME}
VOLUME ${FORTIFY_HOME}
CMD [ "entrypoint.sh" ]