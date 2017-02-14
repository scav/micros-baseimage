# Dockerfile prepared for microservices in java

This Dockerfile was created for running a java-process with a bias towards [Dropwizard](http://dropwizard.io).

Assumptions made by this Dockerfile:
* a Maven project
* pom.xml file in the same dir
* docker-config.yml file in same dir
* docker.properties file in same dir

The ```docker-config.yml``` will be renamed to config.yml in the /opt/$service_name directory.

The Dockerfile will upon building your child image execute a [```ONBUILD```](https://docs.docker.com/reference/builder/#onbuild)
 statement that prepares the environment with the given settings.

This image is built on [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker). Go there for extensive
documentation on how the low-level stuff works.

## docker.properties
The two/three variables needed here is ```service_name``` and ```repo_path```. 
The repo-path will point to a http(s) location
and download the jar-file with ```curl```. 
The variable ```service_version``` will also be available when the ```curl```
command executes, so you can build a maven repo-path.
If your version ends with a -SNAPSHOT the variable ```snapshot_repo_path``` will be used place of ```repo_path```.


NOTE: you can't use theese variables in your own build - as the are only set during one ```RUN``` instruction

##  Runtime variables
See the [variables](https://github.com/phusion/baseimage-docker#environment_variables) documentation from
[phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) to see how it works.

This Dockerfile exposes these variables to the running image:

###```SERVICE_NAME```

The service name is fetched from the docker.properties file and made into a system variable. This is also the name of the process starting the microservice process.


###```SERVICE_VERSION```

The service version is made available from the pom.xml



###```SERVICE_CONFIG```d
Simply points to the /opt/$SERVICE_NAME/config.yml

###```SERVICE_CMD```

This is default set to ```server```, but can be overridden so that it can e.g ```migrate``` instead of ```server```. If the command is set to anything else than ```server``` the service will run once during startup of container with this command. After successful return the ```SERVICE_CMD``` is rewritten to ```server``` and server starts normally.




###```JAVA_OPTIONS```

This is set to a long list of default values, fetched and adapted form a
[post](https://groups.google.com/d/msg/dropwizard-user/PPgqS2ZHeFg/OoSq0yWMBwAJ) in the dropwizard discussion groups.


###```JAVA_MEMORY```

This is a convenience variable, as you don't need to reiterate all ```JAVA_OPTIONS``` just to change the memory settings.


###```JAVA_LOGGC```

This variable is set at image build-time since it relies on the log-folder location.



### Example docker.properties:
```
service_name=my-docker-service
repo=releases
#repo=snapshots

#The version reference will be added by docker during build (from pom.xml)
#while referencing with ${service_name} works - the service name can be hardcoded here.
repo_path=http://user:pass@repo.example.com/${repo}/com/example/${service_name}/${version}/${service_name}-${version}.jar

```

## pom.xml
The Dockerfile will extract the project.version variable to get hold of the current version of the service and expose it
in a ```service_version``` variable while building the image, and set it to a ```SERVICE_VERSION``` variable available
at runtime.

## docker-config.yml

This is your vanilla configuration file. It can be overridden by the use of volumes and SERVICE_OPTION variables.

## Docker images based on Alpine and Debian
As migration step towards Kubernetes two new images have been created, based on Alpine and Debian Linux distros. The main reason for these new images is that, with the current micros base image based on [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker), each microservice is run in a supervised mode, which might lead to unexpected results in terms of liveness check. Specifically a container might look healty from outside when the processes running inside is being restarted by the supervisor.
Container inheriting these base images will run the microservice process without supervision, which mean that if the process crashes (missing config value or unhandled exception for example) the whole container will stop the execution. 
### Limitation
* Only the debian based image can be used in a Vimond environment at the moment. Alpine linux does not support ```search``` keyword in ```/etc/resolv.conf``` file (more info [here](https://github.com/gliderlabs/docker-alpine/issues/8)) which makes impossible service communication base on DNS service discovery (```nslookup gatekeeper.ha``` would fail).
* Due to UNIX signal propagation issue from root to non-root user, only the user named after the service name (see ```SERVICE_NAME``` variable above) is allowed to run the container. This can be obtained by defining the docker directive ```USER $SERVICE_NAME``` in your microservice Dockerfile.
* The images are missing an init script (more info [here] (https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)).
