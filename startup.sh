#!/bin/bash

set -e

IFC=$(ifconfig | grep '^[a-z0-9]' | awk '{print $1}' | grep -e ns -e eth0)
IP_ADDRESS=$(ifconfig $IFC | grep 'inet addr' | awk -F : {'print $2'} | awk {'print $1'} | head -n 1)
echo "This node has an IP of " $IP_ADDRESS

if [ -z "$PUBLIC_HOSTNAME" ]; then
  PUBLIC_HOSTNAME=ucdserver
fi

echo "$IP_ADDRESS $PUBLIC_HOSTNAME" >> /etc/hosts

#run db setup scripts
sed -i "s/27000@licenses.example.com/${RCL_URL}/g" /opt/ucd/ucddbinstall/execsql.sql
sed -i "s|http:\/\/localhost:8080|${DEPLOY_SERVER_URL}|g" /opt/ucd/ucddbinstall/execsql.sql
mkdir -p /tmp/ibm-ucd-install
cp -r /opt/ucd/ucddbinstall/database/ /tmp/ibm-ucd-install
cd /opt/ucd/ucddbinstall
sh install-db.sh
if [ $? -eq 0 ]
then
 echo "Finished setting up UCD Database"
else
  echo "Error setting up UCD Database"
  exit $?
fi

/usr/local/bin/wait-for-it.sh --host=$DATABASE_HOST --port=$DATABASE_PORT --timeout=60 -- /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
