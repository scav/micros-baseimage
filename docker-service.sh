#!/bin/sh
#Since /var/log is a mount we have to create the dir:
mkdir -p /var/log/$SERVICE_NAME
chown -R $SERVICE_NAME:$SERVICE_NAME /var/log/$SERVICE_NAME
#Use the newest jar file in the directory:
service_jar=$(ls -1t /opt/${SERVICE_NAME}/*.jar|head -1)
exec /sbin/setuser $SERVICE_NAME java $JAVA_OPTIONS $JAVA_PROMETHEUS_AGENT_OPTIONS $JAVA_MEMORY $JAVA_LOGGC $JAVA_RUNTIME_OPTIONS \
-jar ${service_jar} $SERVICE_CMD $SERVICE_CONFIG  2>&1 |tee /var/log/${SERVICE_NAME}/sysout.log 
