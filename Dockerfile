# build local ibmcloud/ibm-java image first
FROM stackinabox/ibm-java:7.1-3.3

MAINTAINER Tim Pouyer <tpouyer@us.ibm.com>

# Download the ucd install zip and place it into the artifacts folder
ADD artifacts/ibm-ucd-install /tmp/ibm-ucd-install

# we add the file to /tmp and not /tmp/ibm-ucd-install b/c
# we want to append our local install.properties file at the
# end of the install.properties file that came with the installer
# this way we will pick up the correct version number of UCD
ADD install.properties /tmp/install.properties

# install the UCD Server and remove the install files.
RUN apt-get update -qq && \
	apt-get --no-install-recommends install -qq curl unzip apt-utils > /dev/null \
  	&& rm -rf /var/lib/apt/lists/* && \
  	cat /tmp/install.properties >> /tmp/ibm-ucd-install/install.properties && \
	sh /tmp/ibm-ucd-install/install-server.sh && \
	rm -rf /tmp/ibm-ucd-install && \
	rm -f /tmp/install.properties


# HTTP, HTTPS, JMS
EXPOSE 8080
EXPOSE 8443
EXPOSE 7918


# TODO - replace this with install.dir from install.properties - but how?
# For now, override this with --entrypoint=$INSTALL_DIR/bin/server if needed
ENTRYPOINT ["/opt/ibm-ucd/server/bin/server"]
CMD ["run"]
