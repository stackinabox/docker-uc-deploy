[![Build Status](https://travis-ci.org/stackinabox/docker-uc-deploy.svg?branch=travis-ci)](https://travis-ci.org/stackinabox/docker-uc-deploy)

This will install a new UCD server in a Docker container.
This Dockerfile does not requires a local ibmcloud/ibm-java:latest docker
image. Clone the https://github.com/stackinabox/docker-ibm-java.git
repo and follow the instructions in the README.md to build image.

To run:

 - git clone https://github.com/stackinabox/docker-ibm-java.git and build it following the README.md in the repo

 - git clone https://github.com/stackinabox/docker-ibm-java.git

 - Download UCD installer zip and extract it into 'artifacts' folder
   You are on your own for finding this since it's a licensed product

 - Build the image:

````
	docker build -t stackinabox/urbancode-deploy:%version% .
````

 - Now you can run it using:

````
	docker run -d --name urbancode_deploy -e LICENSE=accept -p 7918:7918 -p 8080:8080 -p 8443:8443 stackinabox/urbancode-deploy:%version% 
````

 - you can get to the web console by pointing your browser at https://%your-docker-hostname%:8443  login with admin:admin
