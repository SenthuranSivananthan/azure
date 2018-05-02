#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y apache2
sudo apt-get install -y prips

a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests

# Update Apache 2 configuration
BalancerMembers=""
for ip in `prips $1 $2`
do
        BalancerMembers+=$(echo -ne "\n\r\t")
        BalancerMembers+="BalancerMember http://${ip}:8080/"
done

cat >/etc/apache2/sites-available/000-default.conf <<EOF
<Proxy balancer://mycluster>
   ${BalancerMembers}
</Proxy>

<VirtualHost *:80>
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

        ProxyPass / balancer://mycluster/
</VirtualHost>
EOF

service apache2 restart