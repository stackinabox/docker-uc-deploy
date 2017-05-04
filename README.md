[![Build Status](https://travis-ci.org/stackinabox/docker-uc-deploy.svg?branch=master)](https://travis-ci.org/stackinabox/docker-uc-deploy)

This will install a new UCD server in a Docker container connecting to a MySQL container.
See the docker-compose.yml for an example of how to run.
Clone the https://github.com/stackinabox/docker-ibm-java.git
repo and follow the instructions in the README.md to build image.

To run:

 - git clone https://github.com/stackinabox/docker-ibm-java.git

 - Download UCD installer zip and extract it into 'artifacts' folder
   You are on your own for finding this since it's a licensed product

 - Build the image:

````
	docker build -t stackinabox/urbancode-deploy:%version% .
````

 - Now you can run it using:

````
	docker run -d --name urbancode_deploy -e LICENSE=accept -p 7918:7918 -p 8080:8080 -p 8443:8443 -e DATABASE_USER=<mysqluser> -e DATABASE_PASS=<mysqlpassword> -e DATABASE_NAME=<mysqldbname>-e DATABASE_PORT=<3306> -e DATABASE_HOST=<mysqldbcontainername> --net=<mysqldbcontainernetwork>  stackinabox/urbancode-deploy:%version% 
````

 - you can get to the web console by pointing your browser at https://%your-docker-hostname%:8443  login with admin:admin
