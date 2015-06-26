#!/bin/sh

if [ "$SERVICE_CMD" != "server" ]
then
 	sh /etc/service/${SERVICE_NAME}/run
fi
echo server > /etc/container_environment/SERVICE_CMD