#!/bin/bash
#Notes on variables below. $UPPER_CASE means variables to be evaluated at runtime.
#Variables with $lower_case means the var should used only in the Dockerfile image build phase.
#This is for keeping the confusion at bay.
source /tmp/docker.properties
mkdir /opt
adduser -s /bin/bash -h /opt/$service_name -u ${user_id:-1000}  -D $service_name docker_env
mkdir /var/log/${service_name}

#New relic agent installation
unzip -d /opt/$service_name/ /tmp/newrelic-java.zip
cp /tmp/newrelic.yml /opt/$service_name/newrelic/
mkdir /opt/$service_name/newrelic/extensions/
cp /tmp/newrelic-extensions/*.xml /opt/$service_name/newrelic/extensions/

#Startup script
mv /tmp/docker-service.sh /usr/bin/docker-service.sh
chmod -R a+x /usr/bin/docker-service.sh

#/etc/container_environment variables are exported only in phusion/base-image, not in alpine. Workaround by writing them into /etc/profile and sourcing the file later
echo "export NEW_RELIC_APP_NAME=$service_name" >> /etc/profile
echo "export NEW_RELIC_LOG=STDOUT" >> /etc/profile
echo "export SERVICE_NAME=$service_name" >> /etc/profile
echo "export SERVICE_CMD=server" >> /etc/profile
echo "export SERVICE_CONFIG=/opt/$service_name/config.yml" >> /etc/profile
echo "export JAVA_LOGGC=-Xloggc:/var/log/$service_name/gc.log " >> /etc/profile

#Service files and folders
mv /tmp/docker-config.yml /opt/$service_name/config.yml
mv /tmp/*.jar /opt/$service_name
echo "docker.properties: $(cat /tmp/docker.properties)"
chown -R $service_name:$service_name /var/log/$service_name
chown -R $service_name:$service_name /opt/$service_name
ls -al  /opt/${service_name}
ls -al  /var/log/${service_name}

# cleanup
rm -rf /tmp/*
