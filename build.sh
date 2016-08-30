#!/bin/bash
#Notes on variables below. $UPPER_CASE means variables to be evaluated at runtime, all file names in
#/etc/container_environment will be a variable name with the file content as value.
#Variables with $lower_case means the var should used only in the Dockerfile image build phase.
#This is for keeping the confusion at bay.
source /tmp/docker.properties
useradd -ms /bin/bash -d /opt/$service_name -G docker_env $service_name
mkdir /var/log/${service_name}
mkdir /etc/service/${service_name}

unzip -d /opt/$service_name/ /tmp/newrelic-java.zip
cp /tmp/newrelic.yml /opt/$service_name/newrelic/
echo $service_name >> /etc/container_environment/NEW_RELIC_APP_NAME
echo "STDOUT" >> /etc/container_environment/NEW_RELIC_LOG
mkdir /opt/$service_name/newrelic/extensions/
cp /tmp/newrelic-extensions/*.xml /opt/$service_name/newrelic/extensions/


mv /tmp/docker-service.sh /etc/service/$service_name/run
echo $service_name >> /etc/container_environment/SERVICE_NAME
echo "server" >> /etc/container_environment/SERVICE_CMD
echo "/opt/$service_name/config.yml" >> /etc/container_environment/SERVICE_CONFIG
echo " -Xloggc:/var/log/$service_name/gc.log " >> /etc/container_environment/JAVA_LOGGC

mv /tmp/docker-config.yml /opt/$service_name/config.yml
mv /tmp/*.jar /opt/$service_name
echo "docker.properties: $(cat /tmp/docker.properties)"
chmod -R a+x /etc/service/${service_name}/
chown -R $service_name:$service_name /etc/service/$service_name
chown -R $service_name:$service_name /var/log/$service_name
chown -R $service_name:$service_name /opt/$service_name
ls -al  /opt/${service_name}
ls -al  /var/log/${service_name}
cat /etc/service/${service_name}/run


# cleanup
rm -rf /tmp/*
