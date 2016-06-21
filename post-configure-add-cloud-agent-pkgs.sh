#!/bin/bash

if [ -n $ADD_CLOUD_AGENT_PKGS ]; then

	AGENT_URL=${AGENT_URL:-http://artifacts.stackinabox.io/urbancode/ibm-ucd-platform-agent-packages}
	ARTIFACT_STREAM=latest
	
	curl -O $AGENT_URL/$ARTIFACT_STREAM.txt

	AGENT_VERSION=${AGENT_VERSION:-$(cat $ARTIFACT_STREAM.txt)}
	AGENT_DOWNLOAD_URL=${AGENT_DOWNLOAD_URL:-$AGENT_URL/$AGENT_VERSION/ibm-ucd-platform-agent-packages-$AGENT_VERSION.tgz}

	curl -O  -s $AGENT_DOWNLOAD_URL
	tar -zxf ibm-ucd-platform-agent-packages-$AGENT_VERSION.tgz -C /tmp
	cd /tmp/ibm-ucd-patterns-install/agent-package-install/

	./install-agent-packages.sh -s $DEPLOY_SERVER_URL -a $DEPLOY_SERVER_AUTH_TOKEN

	rm -rf /tmp/ibm-ucd-patterns-install ibm-ucd-platform-agent-packages-$ARTIFACT_VERSION.tgz

fi

exit 0