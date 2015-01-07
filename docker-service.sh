#!/bin/sh
#Since /var/log is a mount we have to create the dir:
mkdir -p /var/log/$SERVICE_NAME
chown $SERVICE_NAME:$SERVICE_NAME /var/log/$SERVICE_NAME
exec /sbin/setuser $SERVICE_NAME java $JAVA_OPTIONS $JAVA_MEMORY $JAVA_LOGGC \
-jar /opt/${SERVICE_NAME}/${SERVICE_NAME}-${SERVICE_VERSION}.jar \
  $SERVICE_OPTIONS >>  /var/log/${SERVICE_NAME}/sysout.log  2>&1
