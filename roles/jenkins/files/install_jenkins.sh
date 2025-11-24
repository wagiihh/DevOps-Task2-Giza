#!/bin/bash

# Create Jenkins directory
mkdir -p /opt/jenkins
cd /opt/jenkins || exit 1

# Download Jenkins WAR using curl
curl -L -o jenkins.war https://get.jenkins.io/war-stable/2.452.2/jenkins.war

echo "Jenkins WAR downloaded successfully to /opt/jenkins/jenkins.war"
