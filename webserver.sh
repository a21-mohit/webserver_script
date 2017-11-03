#!/bin/bash
rpm -q httpd > /dev/null
if [ $? != 0 ]; then
	yum install httpd -y > /dev/null
	echo "httpd installed."
else
	echo "httpd already installed."
fi

if [ ! -d /srv/www/ ]; then
	semanage fcontext -a -t httpd_sys_content_t '/srv/www(/.*)?'
	mkdir -p -m0755 /srv/www
	cat <<EOF >/srv/www/index.html
<html>
<head>
<title>Demo</title>
</head>
<body>
This is demo.
</body>
</html>
EOF
	restorecon -RF /srv/www/ 
	echo "index.html created."
else
	echo "index.html already exists in /var/www/html"
fi

if [ ! -f /etc/httpd/conf.d/01-www.conf ]; then
	cat <<EOF >/etc/httpd/conf.d/01-www.conf
<Directory "/srv/www/">
	AllowOverride None
	Require all granted
</Directory>
<Virtualhost *:80>
	ServerName "www.rhel7vms.com"
	DocumentRoot /srv/www
</Virtualhost>
EOF
	echo "01-www.conf created."
else
	echo "01-www.conf already exists."
fi
if [ "no" == $(firewall-cmd --query-service=http) ]; then
	firewall-cmd --permanent --add-service=http &>/dev/null
	firewall-cmd --reload
fi

if [ "disabled" == $(systemctl is-enabled httpd) ]; then
	systemctl enable httpd > /dev/null
	echo "httpd enabled."
else
	echo "httpd is already enabled."
fi

if [ $(systemctl is-active httpd) == "inactive" ]; then
	systemctl start httpd
	echo "httpd started."
else
	echo "httpd already active."
fi
