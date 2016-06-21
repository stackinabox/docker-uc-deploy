FROM stackinabox/ibm-supervisord:3.2.2

MAINTAINER Tim Pouyer <tpouyer@us.ibm.com>

# Pass in the location of the UCD install zip 
ARG ARTIFACT_DOWNLOAD_URL 
ARG ARTIFACT_VERSION

# Add startup.sh script and addtional supervisord config
ADD startup.sh /opt/startup.sh
ADD supervisord.conf /tmp/supervisord.conf

# Copy in installation properties
ADD install.properties /tmp/install.properties

# Pass in the location of the UCD agent cloud package tgz
ENV AGENT_DOWNLOAD_URL=${AGENT_DOWNLOAD_URL:-} \
	AGENT_VERSION=${AGENT_VERSION:-}

ADD post-configure-add-cloud-agent-pkgs.sh /root/post-configure-add-cloud-agent-pkgs.sh

# Expose Ports
EXPOSE 8080
EXPOSE 8443
EXPOSE 7918

# install the UCD Server and remove the install files.
RUN wget $ARTIFACT_DOWNLOAD_URL && \
	unzip -q ibm-ucd-$ARTIFACT_VERSION.zip -d /tmp && \
	cat /tmp/install.properties >> /tmp/ibm-ucd-install/install.properties && \
	sh /tmp/ibm-ucd-install/install-server.sh && \
	cat /tmp/supervisord.conf >> /etc/supervisor/conf.d/supervisord.conf && \
	rm -rf /tmp/ibm-ucd-install /tmp/install.properties /tmp/supervisord.conf ibm-ucd-$ARTIFACT_VERSION.zip

ENTRYPOINT ["/opt/startup.sh"]
CMD []
