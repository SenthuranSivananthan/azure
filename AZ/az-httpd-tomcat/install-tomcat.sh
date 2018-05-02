#!/bin/sh

sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get install -y default-jre tomcat8

uname -n > /var/lib/tomcat8/webapps/ROOT/server.txt