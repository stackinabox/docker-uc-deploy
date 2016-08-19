#!/bin/sh
# Licensed Materials - Property of IBM Corp.
# IBM UrbanCode Build
# IBM UrbanCode Deploy
# IBM UrbanCode Release
# IBM AnthillPro
# (c) Copyright IBM Corporation 2002, 2014. All Rights Reserved.
#
# U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by
# GSA ADP Schedule Contract with IBM Corp.

# save current state
PREVIOUS_DIR=`pwd`
PREVIOUS_ANT_HOME=$ANT_HOME
OUR_ANT_VERSION=1.7.1

# now change the dir to the root of the installer
SHELL_NAME=$0
SHELL_PATH=`dirname ${SHELL_NAME}`
FIPS_ARG=$1

if [ "." = "$SHELL_PATH" ]
then
   SHELL_PATH=`pwd`
fi
cd "${SHELL_PATH}"

# set ANT_HOME
ANT_HOME=opt/apache-ant-${OUR_ANT_VERSION}
export ANT_HOME

# set heap memory to 2gb
ANT_OPTS="-Xmx2048m"

# set fips if enabled
if [ "-fips" = "$FIPS_ARG" ]
then
   ANT_OPTS=$ANT_OPTS" -Dcom.ibm.jsse2.usefipsprovider=true"
fi
export ANT_OPTS

# run the install
chmod +x "opt/apache-ant-${OUR_ANT_VERSION}/bin/ant"
sleep 10
opt/apache-ant-${OUR_ANT_VERSION}/bin/ant -nouserlib -noclasspath -f installdb.with.ant.xml

# restore previous state
cd "${PREVIOUS_DIR}"
ANT_HOME=${PREVIOUS_ANT_HOME}
export ANT_HOME
