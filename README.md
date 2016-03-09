This will install a new UCD server in a Docker container.
This Dockerfile does not requires a local ibmcloud/ibm-java:latest docker
image. Clone the https://github.com/stackinabox/docker-ibm-java.git
repo and follow the instructions in the README.md to build image.

To run:

Download UCD installer zip and extract it into 'artifacts' folder

Now just build and run the image:

docker build -t stackinabox/urbancode-deploy:%version% .
docker run stackinabox/urbancode-deploy:latest

# use `docker ps` to view the port mappings
