#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
locale-gen en_US.UTF-8

# Install Some PPAs
apt-get install -y software-properties-common curl
apt-add-repository ppa:nginx/development -y
apt-add-repository ppa:chris-lea/redis-server -y
apt-add-repository ppa:ondrej/php -y
apt-get update

# Install Some Basic Packages
apt-get install -y build-essential dos2unix gcc git libmcrypt4 libpcre3-dev \
make python2.7-dev python-pip re2c supervisor unattended-upgrades whois vim libnotify-bin

# Set My Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install PHP 7.1
apt-get install -y --force-yes php7.1-cli php7.1-dev \
php7.1-pgsql php7.1-sqlite3 php7.1-gd \
php7.1-curl php7.1-memcached \
php7.1-imap php7.1-mysql php7.1-mbstring \
php7.1-xml php7.1-zip php7.1-bcmath php7.1-soap \
php7.1-intl php7.1-readline php-xdebug

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
# Add Composer Global Bin To Path
printf "\nPATH=\"$(sudo su - ubuntu -c 'composer config -g home 2>/dev/null')/vendor/bin:\$PATH\"\n" | tee -a /home/ubuntu/.profile

# Set Some PHP CLI Settings
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/cli/php.ini

# Install Nginx & PHP-FPM
apt-get install -y --force-yes nginx php7.1-fpm
service nginx restart


# Setup Some PHP-FPM Options
echo "xdebug.remote_enable = 1" >> /etc/php/7.1/mods-available/xdebug.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php/7.1/mods-available/xdebug.ini
echo "xdebug.remote_port = 9000" >> /etc/php/7.1/mods-available/xdebug.ini
echo "xdebug.max_nesting_level = 512" >> /etc/php/7.1/mods-available/xdebug.ini
echo "opcache.revalidate_freq = 0" >> /etc/php/7.1/mods-available/opcache.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.1/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.1/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/fpm/php.ini

# Disable XDebug On The CLI

sudo phpdismod -s cli xdebug

# Copy fastcgi_params to Nginx because they broke it on the PPA

cat > /etc/nginx/fastcgi_params << EOF
fastcgi_param	QUERY_STRING		\$query_string;
fastcgi_param	REQUEST_METHOD		\$request_method;
fastcgi_param	CONTENT_TYPE		\$content_type;
fastcgi_param	CONTENT_LENGTH		\$content_length;
fastcgi_param	SCRIPT_FILENAME		\$request_filename;
fastcgi_param	SCRIPT_NAME		\$fastcgi_script_name;
fastcgi_param	REQUEST_URI		\$request_uri;
fastcgi_param	DOCUMENT_URI		\$document_uri;
fastcgi_param	DOCUMENT_ROOT		\$document_root;
fastcgi_param	SERVER_PROTOCOL		\$server_protocol;
fastcgi_param	GATEWAY_INTERFACE	CGI/1.1;
fastcgi_param	SERVER_SOFTWARE		nginx/\$nginx_version;
fastcgi_param	REMOTE_ADDR		\$remote_addr;
fastcgi_param	REMOTE_PORT		\$remote_port;
fastcgi_param	SERVER_ADDR		\$server_addr;
fastcgi_param	SERVER_PORT		\$server_port;
fastcgi_param	SERVER_NAME		\$server_name;
fastcgi_param	HTTPS			\$https if_not_empty;
fastcgi_param	REDIRECT_STATUS		200;
EOF

# Set The Nginx & PHP-FPM User
sed -i "s/user www-data;/user ubuntu;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf
sed -i "s/user = www-data/user = ubuntu/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = ubuntu/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/listen\.owner.*/listen.owner = ubuntu/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = ubuntu/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.1/fpm/pool.d/www.conf

echo "Configure our test site"
cp /vagrant/files/nginx.vhost.conf /etc/nginx/sites-available/test.app
ln -s /etc/nginx/sites-available/test.app /etc/nginx/sites-enabled/test.app

service nginx restart
service php7.1-fpm restart

# Add ubuntu User To WWW-Data
usermod -a -G www-data ubuntu
id ubuntu
groups ubuntu

# Install MySQL
debconf-set-selections <<< "mysql-community-server mysql-community-server/data-dir select ''"
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password secret"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password secret"
apt-get install -y mysql-server
# Configure MySQL Password Lifetime
echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf
# Configure MySQL Remote Access
sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
service mysql restart
mysql --user="root" --password="secret" -e "CREATE USER 'ubuntu'@'0.0.0.0' IDENTIFIED BY 'secret';"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'ubuntu'@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'ubuntu'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql --user="root" --password="secret" -e "FLUSH PRIVILEGES;"
mysql --user="root" --password="secret" -e "CREATE DATABASE ubuntu;"
service mysql restart

# Add Timezone Support To MySQL
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=secret mysql


apt-get -y autoremove
apt-get -y clean