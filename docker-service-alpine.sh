#!/bin/bash
source /etc/profile

service_jar=$(ls -1t /opt/${SERVICE_NAME}/*.jar|head -1)

JAVA_NEW_RELIC_OPTIONS=""
if [ -n "$NEW_RELIC_LICENSE_KEY" ]; then
    JAVA_NEW_RELIC_OPTIONS="-javaagent:/opt/$SERVICE_NAME/newrelic/newrelic.jar"
fi

java_exec="java $JAVA_OPTIONS $JAVA_NEW_RELIC_OPTIONS $JAVA_PROMETHEUS_AGENT_OPTIONS $JAVA_MEMORY $JAVA_LOGGC $JAVA_RUNTIME_OPTIONS -jar ${service_jar} $@  $SERVICE_CONFIG"

if [ "$(whoami)" == "root" ] ; then
    echo "Running the container as a root, it won't propagate SIGTERM signal.\nTo avoid this specify the directive 'USER ${SERVICE_NAME}' into your service Dockerfile"
    exit 1
elif [ "$(whoami)" == ${SERVICE_NAME} ]; then
    exec $java_exec
else
    echo "$(whoami) not authorised to start the service process"
fi
