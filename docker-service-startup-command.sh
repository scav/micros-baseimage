#!/bin/sh

if [ "$SERVICE_CMD" != "server" ]
then
 	sh /etc/service/docker-service/run
fi
echo server > /etc/container_environment/SERVICE_CMD