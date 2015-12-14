#!/bin/sh

if [ "$SERVICE_CMD" != "server" ]
then
 	bash -c "/etc/service/${SERVICE_NAME}/run"
fi

exit_code=$?

if [ $exit_code -eq 0 ]; then
	echo server > /etc/container_environment/SERVICE_CMD
fi

exit $exit_code