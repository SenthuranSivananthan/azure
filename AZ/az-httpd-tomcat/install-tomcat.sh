#!/bin/sh

sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get install -y default-jre tomcat8

uname -n > /usr/share/tomcat8-root/default_root/server.txt