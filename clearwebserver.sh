#!/bin/bash
yum remove httpd -y > /dev/null
rm -rf /srv/
rm -f /etc/httpd/conf.d/01-www.conf
firewall-cmd --permanent --remove-service=http
firewall-cmd --reload
semanage fcontext -d '/srv/www(/.*)?'
