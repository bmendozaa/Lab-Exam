#!/bin/sh

echo "Installing HTTPD"
yum install -y httpd

echo "Starting HTTPD"
systemctl start httpd.service


# Adding firewall to allow trusted traffic to bypass the firewall


firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

# To install mysql php

yum install -y php php-mysql


echo "Restart HTTPD"

systemctl restart httpd.service

echo "findout"
yum info php-fpm

echo "Installing PHP-FPM"
yum install -y php-fpm

cd /var/www/html/
echo '<?php phpinfo(); ?>' > index.php

echo "Installing MariaDB"
yum install -y mariadb-server mariadb

echo "Starting MariaDB"
systemctl start mariadb

echo "Running simple security script"
mysql_secure_installation <<EOF
y
root12345
root12345
y
y
y
y
EOF


echo "enable MariaDB"
systemctl enable mariadb


echo "Verifying version"
mysqladmin -u root -proot12345 version

echo "CREATE DATABASE wordpress; CREATE USER bru@localhost IDENTIFIED BY 'root12345'; GRANT ALL PRIVILEGES ON wordpress.* TO bru@localhost IDENTIFIED BY 'root12345'; FLUSH PRIVILEGES; show databases;" | mysql -u root -proot12345


echo "Installing wordpress"
yum install -y php-gd
echo "Restarting Apache"
service httpd restart

echo "Installing wget"
yum install -y wget

echo "Installing tar"
yum install -y tar

cd /opt/
wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz

echo "Installing Rsync"
yum install -y rsync
rsync -avP wordpress/ /var/www/html/
cd /var/www/html/
mkdir /var/www/html/wp-content/uploads
chown -R apache:apache /var/www/html/*
cp wp-config-sample.php wp-config.php
sed -i 's/database_name_here/wordpress/g' wp-config.php
sed -i 's/username_here/bru/g' wp-config.php
sed -i 's/password_here/root12345/g' wp-config.php

echo "Updating php"
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install -y yum-utils
yum-config-manager --enable remi-php56
yum install -y php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
systemctl restart httpd.service