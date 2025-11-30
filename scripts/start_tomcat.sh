#!/bin/bash

export JAVA_HOME=/home/pet-clinic/java/jdk-25.0.1
export PATH=$JAVA_HOME/bin:$PATH

# Stop any running Tomcat
pkill -f tomcat || true

# Start Tomcat fully detached
nohup /home/pet-clinic/tomcat/bin/startup.sh >/home/pet-clinic/tomcat/tomcat.log 2>&1 &

exit 0
