#!/bin/bash
rpm -q httpd > /dev/null
if [ $? != 0 ]; then
	yum install httpd -y > /dev/null
	echo "httpd installed."
else
	echo "httpd already installed."
fi

if [ ! -f /var/www/html/index.html ]; then
	cat <<EOF >/var/www/html/index.html
<html>
<head>
<title>Demo</title>
</head>
<body>
This is demo.
</body>
</html>
EOF
	echo "index.html created."
else
	echo "index.html already exists in /var/www/html"
fi

restorecon -vvRF /var/www/html &> /dev/null

if [ "no" == $(firewall-cmd --query-service=http) ]; then
	firewall-cmd --permanent --add-service=http &>/dev/null
	firewall-cmd --reload
fi

if [ "inactive" == $(systemctl is-active httpd) ]; then
	systemctl start httpd > /dev/null
	echo "httpd started."
else
	echo "httpd already active."
fi

if [ "disabled" == $(systemctl is-enabled httpd) ]; then
	systemctl enable httpd > /dev/null
	echo "httpd enabled."
else
	echo "httpd is already enabled."
fi
