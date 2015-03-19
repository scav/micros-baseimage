# vim:set ft=dockerfile:
FROM phusion/baseimage:0.9.15
MAINTAINER Olve Sæther Hansen <olve@vimond.com>

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]


# automatically accept oracle license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true \
    | /usr/bin/debconf-set-selections


RUN add-apt-repository ppa:webupd8team/java \
   && apt-get update \
   && apt-get -y upgrade \
   && apt-get -y install \
       python-software-properties \
       python-pip \
       oracle-java8-installer \
       oracle-java8-set-default \
       oracle-java8-unlimited-jce-policy \
       libsnappy-java \
       libxml2-utils \
   && apt-get clean   \
   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN pip install cqlsh

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Swaps (ubuntu) dash with bash for easier sourcein
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

COPY docker-service.sh /tmp/docker-service.sh
COPY docker-service-startup-command.sh /etc/my_init.d/docker-service-startup-command.sh
RUN chmod a+x /etc/my_init.d/docker-service-startup-command.sh
ONBUILD COPY docker-config.yml docker.properties pom.xml /tmp/


#Notes on variables below. $UPPER_CASE means variables to be evaluated at runtime, all file names in
#/etc/container_environment will be a variable name with the file content as value.
#Variables with $lower_case means the var should used only in the Dockerfile image build phase.
#This is for keeping the confusion at bay.
ONBUILD RUN  source /tmp/docker.properties \
      && xmllint --xpath "//*[local-name()='project']/*[local-name()='version']/text()" /tmp/pom.xml > /tmp/version.txt \
      && echo "service_version=$(cat /tmp/version.txt)" >> /etc/my-service-variables.properties \
      && cat /tmp/docker.properties >> /etc/my-service-variables.properties \
      && source /etc/my-service-variables.properties \
      && useradd -ms /bin/bash -d /opt/$service_name -G docker_env $service_name \
      && mkdir /var/log/${service_name} \
      && mkdir /etc/service/${service_name} \
      && mv /tmp/docker-service.sh /etc/service/$service_name/run  \
      && echo $service_name >> /etc/container_environment/SERVICE_NAME \
      && echo $service_version >> /etc/container_environment/SERVICE_VERSION \
      && echo "server" >> /etc/container_environment/SERVICE_CMD \
      && echo "/opt/$service_name/config.yml" >> /etc/container_environment/SERVICE_CONFIG \
      && echo " -Xloggc:/var/log/$service_name/gc.log " >> /etc/container_environment/JAVA_LOGGC \
      && mv /tmp/docker-config.yml /opt/$service_name/config.yml \
      && echo "docker.properties: $(cat /tmp/build_docker.properties)" \
      && if [[ "$service_version" = *"-SNAPSHOT" ]] ; then export chosen_repo=$snapshot_repo_path ; else export chosen_repo=$repo_path ; fi \
      && curl -f -v -o /opt/${service_name}/${service_name}-${service_version}.jar ${chosen_repo} \
      && chmod -R a+x /etc/service/${service_name}/ \
      && chown -R $service_name:$service_name /etc/service/$service_name \
      && chown -R $service_name:$service_name /var/log/$service_name \
      && chown -R $service_name:$service_name /opt/$service_name  \
      && ls -al  /opt/${service_name}    \
      && ls -al  /var/log/${service_name} \
      && cat /etc/service/${service_name}/run    \
      && rm -rf /tmp/


                                                           
#All variables here will also be written to /etc/container_environment/VAR_NAME
ENV JAVA_MEMORY -Xms500m -Xmx500m

# +UseNUMA                    make sure we use NUMA-specific GCs if possible
# +UserCompressedOops         use 32-bit pointers to reduce heap usage
# +UseParNewGC                use parallel GC for the new generation
# +UseConcMarkSweepGC         use concurrent mark-and-sweep for the old generation
# +CMSParallelRemarkEnabled   use multiple threads for the remark phase
# +AggressiveOpts             use the latest and greatest in JVM tech
# +UseFastAccessorMethods     be sure to inline simple accessor methods
# +UseBiasedLocking           speed up uncontended locks
# +NewRatio                   set eden/survivor spaces fraction of heap
# +HeapDumpOnOutOfMemoryError   dump the heap if we run out of memory
# +HeapDumpPath=/opt/gatekeeper dump the heap to path

#TODO: this list of options should be revised in light of changes in GC for Java 8
ENV JAVA_OPTIONS -server \
-d64 \
-Djava.net.preferIPv4Stack=true \
-XX:+UseNUMA \
-XX:+UseCompressedOops \
-XX:+UseParNewGC \
-XX:+UseConcMarkSweepGC \
-XX:+CMSParallelRemarkEnabled \
-XX:+AggressiveOpts \
-XX:+UseFastAccessorMethods \
-XX:+UseBiasedLocking \
-XX:NewRatio=2 \
-XX:+HeapDumpOnOutOfMemoryError \
-XX:HeapDumpPath=/opt/gatekeeper \
-XX:+PrintGC \
-XX:+PrintGCDetails \
-XX:+PrintGCTimeStamps \
-XX:GCLogFileSize=20M \
-XX:NumberOfGCLogFiles=15 \
-XX:+UseGCLogFileRotation \
-XX:+PrintGCDateStamps \
-XX:+PrintPromotionFailure \
-Djava.security.egd=file:/dev/urandom \
-Dcom.sun.management.jmxremote \
-Dcom.sun.management.jmxremote.port=9010 \
-Dcom.sun.management.jmxremote.rmi.port=9010
-Dcom.sun.management.jmxremote.local.only=false \
-Dcom.sun.management.jmxremote.authenticate=false \
-Dcom.sun.management.jmxremote.ssl=false \
-XX:-ReduceInitialCardMarks

#TODO: Check that jmx works through docker.
#http://ptmccarthy.github.io/2014/07/24/remote-jmx-with-docker/
#-Dcom.sun.management.jmxremote.rmi.port=9010

# for arbritrary settings and configurations 
# e.g. -Ddw.cassandra.cassandraContactPoints[0]=10.0.0.123
# as . is not allowed in bash variables
#ENV JAVA_RUNTIME_OPTIONS

# alternative:
# ENV SERVICE_OPTIONS migrate /opt/YOUR_SERVICE_NAME/config.yml

#To use this the SERVICE_OPTIONS variable must reflect the path to the configuration file here
VOLUME /etc/alternative-config

#Otherwise you might overwrite the config-file with the explicit path to
#the existing configuration file - /opt/$SERVICE_NAME/config.yml
#VOLUME /opt/$SERVICE_NAME/config.yml

#JMX:
EXPOSE 9010
