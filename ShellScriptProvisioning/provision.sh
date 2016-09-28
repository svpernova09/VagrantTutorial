#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

echo "Updating Package List"
apt-get update
echo "Updating System Packages"
apt-get -y upgrade

#echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
#locale-gen en_US.UTF-8
#
#echo "Installing Nginx and PHP PPA Repos"
#apt-get install -y software-properties-common curl
#apt-add-repository ppa:nginx/development -y
#apt-add-repository ppa:ondrej/php -y
#
#echo "Updating Package list with new Repos"
#apt-get update
#
#echo "Install some basic packages (git, python, vim)"
#apt-get install -y build-essential dos2unix gcc git libmcrypt4 libpcre3-dev \
#make python2.7-dev python-pip re2c unattended-upgrades whois vim libnotify-bin
#
#echo "Setting Timezone to UTC"
#ln -sf /usr/share/zoneinfo/UTC /etc/localtime
#
#echo "Install PHP 7"
#apt-get install -y --force-yes php7.0-cli php7.0-dev \
#php-pgsql php-sqlite3 php-gd php-apcu \
#php-curl php7.0-mcrypt \
#php-imap php-mysql php-memcached php7.0-readline php-xdebug \
#php-mbstring php-xml php7.0-zip php7.0-intl php7.0-bcmath php-soap
#
#echo "Install Composer"
#curl -sS https://getcomposer.org/installer | php
#mv composer.phar /usr/local/bin/composer
#printf "\nPATH=\"$(sudo su - vagrant -c 'composer config -g home 2>/dev/null')/vendor/bin:\$PATH\"\n" | tee -a /home/vagrant/.profile
#
#echo "Configuring PHP CLI Settings"
#sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/cli/php.ini
#sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/cli/php.ini
#sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/cli/php.ini
#sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/cli/php.ini
#
#echo "Installing Install Nginx and PHP-FPM"
#apt-get install -y --force-yes nginx php7.0-fpm
#service nginx restart
#
#echo "Configuring PHP-FPM"
#echo "xdebug.remote_enable = 1" >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini
#echo "xdebug.remote_connect_back = 1" >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini
#echo "xdebug.remote_port = 9000" >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini
#echo "xdebug.max_nesting_level = 512" >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini
#
#sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini
#sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini
#sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
#sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/fpm/php.ini
#sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.0/fpm/php.ini
#sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.0/fpm/php.ini
#sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini
#
#echo "Copying fastcgi_params to Nginx"
#cat > /etc/nginx/fastcgi_params << EOF
#fastcgi_param	QUERY_STRING		\$query_string;
#fastcgi_param	REQUEST_METHOD		\$request_method;
#fastcgi_param	CONTENT_TYPE		\$content_type;
#fastcgi_param	CONTENT_LENGTH		\$content_length;
#fastcgi_param	SCRIPT_FILENAME		\$request_filename;
#fastcgi_param	SCRIPT_NAME		\$fastcgi_script_name;
#fastcgi_param	REQUEST_URI		\$request_uri;
#fastcgi_param	DOCUMENT_URI		\$document_uri;
#fastcgi_param	DOCUMENT_ROOT		\$document_root;
#fastcgi_param	SERVER_PROTOCOL		\$server_protocol;
#fastcgi_param	GATEWAY_INTERFACE	CGI/1.1;
#fastcgi_param	SERVER_SOFTWARE		nginx/\$nginx_version;
#fastcgi_param	REMOTE_ADDR		\$remote_addr;
#fastcgi_param	REMOTE_PORT		\$remote_port;
#fastcgi_param	SERVER_ADDR		\$server_addr;
#fastcgi_param	SERVER_PORT		\$server_port;
#fastcgi_param	SERVER_NAME		\$server_name;
#fastcgi_param	HTTPS			\$https if_not_empty;
#fastcgi_param	REDIRECT_STATUS		200;
#EOF
#
#echo "Setting nginx and PHP-FPM user to vagrant"
#sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf
#sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf
#sed -i "s/user = www-data/user = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
#sed -i "s/group = www-data/group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
#sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
#sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
#sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.0/fpm/pool.d/www.conf
#
#service nginx restart
#service php7.0-fpm restart
#
#echo "Adding Vagrant user to WWW-Data user"
#usermod -a -G www-data vagrant
#id vagrant
#groups vagrant
#
#echo "Installing MySQL"
#debconf-set-selections <<< "mysql-community-server mysql-community-server/data-dir select ''"
#apt-get install -y mysql-server
#
#echo "Configuring MySQL"
#echo "default_password_lifetime = 0" >> /etc/mysql/my.cnf
#sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
#mysql --user="root" -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY 'vagrant' WITH GRANT OPTION;"
#service mysql restart
#mysql --user="root" -e "CREATE USER 'vagrant'@'0.0.0.0' IDENTIFIED BY 'vagrant';"
#mysql --user="root" -e "GRANT ALL ON *.* TO 'vagrant'@'0.0.0.0' IDENTIFIED BY 'vagrant' WITH GRANT OPTION;"
#mysql --user="root" -e "GRANT ALL ON *.* TO 'vagrant'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION;"
#mysql --user="root" -e "FLUSH PRIVILEGES;"
#mysql --user="root" -e "CREATE DATABASE vagrant;"
#
#service mysql restart
#
#echo "Finishing Up"
#/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
#/sbin/mkswap /var/swap.1
#/sbin/swapon /var/swap.1
