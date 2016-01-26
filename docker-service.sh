#!/bin/bash
#Since /var/log is a mount we have to create the dir:
mkdir -p /var/log/$SERVICE_NAME
chown -R $SERVICE_NAME:$SERVICE_NAME /var/log/$SERVICE_NAME
#Use the newest jar file in the directory:
service_jar=$(ls -1t /opt/${SERVICE_NAME}/*.jar|head -1)

JAVA_NEW_RELIC_OPTIONS=""
if [ -n "$NEW_RELIC_LICENSE_KEY" ]; then
    JAVA_NEW_RELIC_OPTIONS="-javaagent:/opt/$SERVICE_NAME/newrelic/newrelic.jar"
fi

exec /sbin/setuser $SERVICE_NAME java $JAVA_OPTIONS $JAVA_NEW_RELIC_OPTIONS $JAVA_PROMETHEUS_AGENT_OPTIONS $JAVA_MEMORY $JAVA_LOGGC $JAVA_RUNTIME_OPTIONS \
-jar ${service_jar} $SERVICE_CMD $SERVICE_CONFIG; test ${PIPESTATUS[0]} -eq 0
