FROM stackinabox/ibm-supervisord:3.2.2

MAINTAINER Sudhakar Frederick <sudhakar@au1.ibm.com>

# Pass in the location of the UCD install zip
ARG ARTIFACT_DOWNLOAD_URL
ARG ARTIFACT_VERSION

# Add startup.sh script and addtional supervisord config
ADD startup.sh /opt/startup.sh
ADD supervisord.conf /tmp/supervisord.conf

#Copy in database setup scripts
COPY ./ucddbinstall /opt/ucd/ucddbinstall/

# Copy in installation properties
ADD install.properties /tmp/install.properties

# Add post configure add cloud agent pkgs script
ADD post-configure-add-cloud-agent-pkgs.sh /root/post-configure-add-cloud-agent-pkgs.sh

# Expose Ports
EXPOSE 8080
EXPOSE 8443
EXPOSE 7918

ENV LICENSE=${LICENSE:-} \
    DATABASE_USER=${DATABASE_USER:-ibm_ucd} \
    DATABASE_PASS=${DATABASE_PASS:-passw0rd} \
    DATABASE_NAME=${DATABASE_NAME:-ibm_ucd} \
    DATABASE_PORT=${DATABASE_PORT:-3306} \
    DATABASE_HOST=${DATABASE_HOST:-} \
    DEPLOY_SERVER_URL=${DEPLOY_SERVER_URL:-http://localhost:8080} \
    DEPLOY_SERVER_HOSTNAME=${DEPLOY_SERVER_HOSTNAME:-localhost} \
    DEPLOY_SERVER_AUTH_TOKEN=${DEPLOY_SERVER_AUTH_TOKEN:-} \
    RCL_URL=${RCL_URL:-"27000@licenses.example.com"} \
    ADD_CLOUD_AGENT_PKGS=${ADD_CLOUD_AGENT_PKGS:-}

# install the UCD Server and remove the install files.
RUN mkdir -p /cache && \
    wget -q $ARTIFACT_DOWNLOAD_URL && \
	unzip -q ibm-ucd-$ARTIFACT_VERSION.zip -d /tmp && \
	cat /tmp/install.properties >> /tmp/ibm-ucd-install/install.properties && \
	sh /opt/ucd/ucddbinstall/replaceAntSQL.sh /tmp/ibm-ucd-install && \
	cp /opt/ucd/ucddbinstall/*.jar /tmp/ibm-ucd-install/lib/ext/ && \
	sh /tmp/ibm-ucd-install/install-server.sh && \
	grep ZSQLFILE /tmp/ibm-ucd-install/install.log | cut -f 3- -d '_' > /opt/ucd/ucddbinstall/runsqls.txt && \
	grep ZSQLSTMTBEGIN /tmp/ibm-ucd-install/install.log | cut -f2- -d '_' > /opt/ucd/ucddbinstall/execsql.sql && \
	chmod +x /opt/ucd/ucddbinstall/install-db.sh /opt/startup.sh && \
	cp -r /tmp/ibm-ucd-install/database /opt/ucd/ucddbinstall/ && \
	cat /tmp/supervisord.conf >> /etc/supervisor/conf.d/supervisord.conf && \
	rm -rf /tmp/ibm-ucd-install /tmp/install.properties /tmp/supervisord.conf ibm-ucd-$ARTIFACT_VERSION.zip

VOLUME ["/cache"]

ENTRYPOINT ["/opt/startup.sh"]
CMD []
