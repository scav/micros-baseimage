#!/bin/sh

if [ "$SERVICE_CMD" != "server" ]
then
 	exec /sbin/setuser $SERVICE_NAME /etc/service/${SERVICE_NAME}/run
fi
echo server > /etc/container_environment/SERVICE_CMD