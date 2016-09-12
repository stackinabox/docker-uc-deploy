#!/bin/bash

if [ -n "$ADD_CLOUD_AGENT_PKGS" ]; then

	AGENT_URL=${AGENT_URL:-http://artifacts.stackinabox.io/urbancode/ibm-ucd-platform-agent-packages}
	ARTIFACT_STREAM=latest

	components_exist=

	echo "Looking for previously uploaded platform agent components in UCD server ${DEPLOY_SERVER_URL}..."

	attempt=1
	until $(curl -k -u admin:admin --output /dev/null --silent --head --fail "${DEPLOY_SERVER_URL}/cli/systemConfiguration"); do
		attempt=$(($attempt + 1))
		sleep 10
		if [ "$attempt" -gt "18" ]; then
			echo "Failed to connect to ucd server at ${DEPLOY_SERVER_URL}. Please check for env variable DEPLOY_SERVER_URL for a valid value."
			exit 1
		fi
	done

	components_id=$(curl -k -u admin:admin \
		-X GET \
		"${DEPLOY_SERVER_URL}/rest/deploy/component" | python -c \
"import json; import sys;
data=json.load(sys.stdin); 
for item in data:
	if item['name'] == 'ucd-agent-linux-x86_64':
		print item['id']")

	if [ -n "$components_id" ]; then
		echo "Found previously uploaded platform agent components in UCD server ${DEPLOY_SERVER_URL}. Skipping platform agent component upload."
		echo "Found component id: ${components_id}"
		# already uploaded; simply exit now b/c were done
		exit 0
	fi


	if [ -z "$DEPLOY_SERVER_AUTH_TOKEN" ]; then

		# UCD Server takes a few seconds to startup. If we call this function too early it will fail
		# loop until it succeeds or fail after # of attempts
		attempt=1
		until $(curl -k -u admin:admin --output /dev/null --silent --head --fail "${DEPLOY_SERVER_URL}/cli/systemConfiguration"); do
			attempt=$(($attempt + 1))
			sleep 10
			if [ "$attempt" -gt "18" ]; then
				echo "Failed to connect to ucd server at ${DEPLOY_SERVER_URL}. Please check for env variable DEPLOY_SERVER_URL for a valid value."
				exit 1
			fi
		done

		DEPLOY_SERVER_AUTH_TOKEN=$(curl -k -u admin:admin \
			-X PUT \
			"${DEPLOY_SERVER_URL}/cli/teamsecurity/tokens?user=admin&expireDate=12-31-2020-12:00" | python -c \
"import json; import sys;
data=json.load(sys.stdin); 
print data['token']")
	fi

	wget -Nv $AGENT_URL/$ARTIFACT_STREAM.txt

	AGENT_VERSION=${AGENT_VERSION:-$(cat $ARTIFACT_STREAM.txt)}
	AGENT_DOWNLOAD_URL=${AGENT_DOWNLOAD_URL:-$AGENT_URL/$AGENT_VERSION/ibm-ucd-platform-agent-packages-$AGENT_VERSION.tgz}

	cd /cache
	wget -Nv $AGENT_DOWNLOAD_URL
	tar -zxf ibm-ucd-platform-agent-packages-$AGENT_VERSION.tgz
	cd /cache/ibm-ucd-patterns-install/agent-package-install/

	sed -i 's|#!\/bin\/sh|#!\/bin\/bash|g' /cache/ibm-ucd-patterns-install/agent-package-install/install-agent-packages.sh
	/bin/bash -c "`pwd`/install-agent-packages.sh -s ${DEPLOY_SERVER_URL} -a ${DEPLOY_SERVER_AUTH_TOKEN}"

	rm -rf /cache/ibm-ucd-patterns-install
	#rm -rf /cache/ibm-ucd-patterns-install ibm-ucd-platform-agent-packages-$ARTIFACT_VERSION.tgz

fi

exit 0