#!/bin/bash

set -e

IFC=$(ifconfig | grep '^[a-z0-9]' | awk '{print $1}' | grep -e ns -e eth0)
IP_ADDRESS=$(ifconfig $IFC | grep 'inet addr' | awk -F : {'print $2'} | awk {'print $1'} | head -n 1)
echo "This node has an IP of " $IP_ADDRESS

if [ -z "$PUBLIC_HOSTNAME" ]; then  
  PUBLIC_HOSTNAME=localagent
fi

echo "$IP_ADDRESS $PUBLIC_HOSTNAME" >> /etc/hosts

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf