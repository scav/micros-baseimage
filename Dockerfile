# vim:set ft=dockerfile:
FROM vimond-docker-dockerv2-local.artifactoryonline.com/vimond-base-java-8
MAINTAINER Olve Sæther Hansen <olve@vimond.com>

# Promotheus JMX exporter java agent
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.5/jmx_prometheus_javaagent-0.5.jar /tmp/jmx_prometheus_javaagent-0.5.jar
COPY prometheus.yml /tmp/prometheus.yml

ADD https://download.newrelic.com/newrelic/java-agent/newrelic-agent/3.22.1/newrelic-java.zip /tmp/newrelic-java.zip
COPY newrelic.yml /tmp/newrelic.yml

COPY docker-service.sh /tmp/docker-service.sh
COPY docker-service-startup-command.sh /etc/my_init.d/docker-service-startup-command.sh
RUN chmod a+x /etc/my_init.d/docker-service-startup-command.sh
COPY build.sh /tmp/build.sh
RUN chmod a+x /tmp/build.sh

ONBUILD COPY docker/docker-config.yml docker/docker.properties build/libs/*.jar target/*.jar /tmp/
ONBUILD RUN rm -fv /tmp/*tests*.jar


ONBUILD RUN /tmp/build.sh

#All variables here will also be written to /etc/container_environment/VAR_NAME
ENV JAVA_MEMORY -Xms500m -Xmx500m


# Set this to a valid new relic license key to activate the new relic agent
ENV NEW_RELIC_LICENSE_KEY ""


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
-Dcom.sun.management.jmxremote.rmi.port=9010 \
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
# ENV SERVICE_OPTIONS migrate 

#To use this the SERVICE_CONFIGURATION variable must reflect the path to the configuration file here
VOLUME /etc/alternative-config
# ENV SERVICE_CONFIGURATION /etc/alternative-config

#Otherwise you might overwrite the config-file with the explicit path to
#the existing configuration file - /opt/$SERVICE_NAME/config.yml
#VOLUME /opt/$SERVICE_NAME/config.yml

# Overridable in docker.properties
ENV enable_prometheus true

#JMX:
EXPOSE 9010

# JMX EXPORTER
EXPOSE 9012
