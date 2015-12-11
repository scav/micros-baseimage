#!/bin/sh

if [ "$SERVICE_CMD" != "server" ]
then
 	exec /etc/service/${SERVICE_NAME}/run && echo server > /etc/container_environment/SERVICE_CMD
fi