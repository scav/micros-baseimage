#!/bin/sh

if [ "$SERVICE_CMD" != "server" ]
then
 	sh /etc/service/${service_name}/run
fi
echo server > /etc/container_environment/SERVICE_CMD