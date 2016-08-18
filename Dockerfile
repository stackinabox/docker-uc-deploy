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

# Expose Ports
EXPOSE 8080
EXPOSE 8443
EXPOSE 7918

# install the UCD Server and remove the install files.
RUN wget -q $ARTIFACT_DOWNLOAD_URL && \
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

ENTRYPOINT ["/opt/startup.sh"]
CMD []
