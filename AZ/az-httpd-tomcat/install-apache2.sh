#!bin/sh

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y apache2

a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests

service apache2 restart

