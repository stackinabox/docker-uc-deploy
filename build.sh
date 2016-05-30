#!/usr/bin/env sh

#### 
#  The following variables must be set in the build.rc file before executing this script
####
ARTIFACT_URL=${ARTIFACT_URL:-http://artifacts.stackinabox.io/urbancode/ibm-ucd}

source ./build.rc

####
# UCD_VERSION will be read from the stream file on the artifact server so no need to set it
####
echo "artifact stream url: $ARTIFACT_URL/$ARTIFACT_STREAM.txt"
curl -O $ARTIFACT_URL/$ARTIFACT_STREAM.txt
ARTIFACT_VERSION=${ARTIFACT_VERSION:-$(cat $ARTIFACT_STREAM.txt)}
ARTIFACT_DOWNLOAD_URL=${ARTIFACT_DOWNLOAD_URL:-$ARTIFACT_URL/$ARTIFACT_VERSION/ibm-ucd-$ARTIFACT_VERSION.zip}

echo "artifact stream url: $ARTIFACT_URL/$ARTIFACT_STREAM.txt"
echo "artifact version:  $ARTIFACT_VERSION"
echo "artifact download url: $ARTIFACT_DOWNLOAD_URL"

docker login -e="$DOCKER_EMAIL" -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
docker build -t stackinabox/urbancode-deploy:$ARTIFACT_VERSION --build-arg ARTIFACT_DOWNLOAD_URL=$ARTIFACT_DOWNLOAD_URL --build-arg ARTIFACT_VERSION=$ARTIFACT_VERSION .
docker push stackinabox/urbancode-deploy:$ARTIFACT_VERSION
