#!/bin/bash
 
#####################################################################################
#                                                                                   #
# * Ubuntu APMinstaller v.1.5.4                                                     #
# * Ubuntu 18.04.5-live-server                                                      #
# * Apache 2.4.X , MariaDB 10.5.X, Multi-PHP(base php7.2) setup shell script        #
# * Created Date    : 2021/12/24                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

##########################################
#                                        #
#           repositories update          #
#                                        #
########################################## 

sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8

sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mariadb.mirror.liquidtelecom.com/repo/10.5/ubuntu $(lsb_release -cs) main"
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu bionic main multiverse restricted universe"
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu bionic-security main multiverse restricted universe"
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu bionic-updates main multiverse restricted universe"

apt-get -y install git zip unzip sendmail glibc* zlib1g-dev gcc g++ make git autoconf autogen automake \
pkg-config libuuid-devel libc-dev curl wget gnupg2 ca-certificates lsb-release apt-transport-https

apt-get -y update && sudo apt-get -y upgrade

##########################################
#                                        #
#           아파치2 및 HTTP2 설치            #
#                                        #
########################################## 

# apache2 설치
apt-get -y install apache2 libapache2-mod-fcgid

##########################################
#                                        #
#               firewalld                #
#                                        #
##########################################  

ufw enable

ufw allow 22

ufw allow 80

ufw allow 443

ufw allow 3306

ufw allow 9090

systemctl restart apache2

##########################################
#                                        #
#           httpd.conf   Setup           #
#                                        #
##########################################  

sed -i 's/#AddDefaultCharset/AddDefaultCharset/' /etc/apache2/conf-available/charset.conf
sed -i 's/ServerTokens OS/ServerTokens Prod/' /etc/apache2/conf-available/security.conf
sed -i 's/ServerSignature On/ServerSignature Off/' /etc/apache2/conf-available/security.conf
sed -i 's/#<Directory \/>/<Directory \/>/' /etc/apache2/conf-available/security.conf
sed -i 's/#   AllowOverride None/   AllowOverride None/' /etc/apache2/conf-available/security.conf
sed -i '10s/#   Require all denied/   Require all denied/' /etc/apache2/conf-available/security.conf
sed -i 's/#<\/Directory>/<\/Directory>/' /etc/apache2/conf-available/security.conf
sed -i 's/#ServerName www.example.com/ServerName localhost/' /etc/apache2/sites-available/000-default.conf
sed -i '/ServerAdmin/i\                ServerName localhost' /etc/apache2/sites-available/default-ssl.conf
sed -i '/# Global configuration/i\ServerName localhost' /etc/apache2/apache2.conf

echo '<IfModule mod_userdir.c>
        UserDir public_html
        UserDir disabled root

        <Directory /var/www/*/public_html>
                AllowOverride FileInfo AuthConfig Limit Indexes
                Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
                Require method GET POST OPTIONS
        </Directory>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet ' > /etc/apache2/mods-available/userdir.conf

echo '# deny file, folder start with dot
<DirectoryMatch "^\.|\/\.">
    Require all denied
</DirectoryMatch>
 
# deny (log file, binary, certificate, shell script, sql dump file) access.
<FilesMatch "\.(?i:log|binary|pem|enc|crt|conf|cnf|sql|sh|key|yml|lock|gitignore)$">
    Require all denied
</FilesMatch>
 
# deny access.
<FilesMatch "(?i:composer\.json|contributing\.md|license\.txt|readme\.rst|readme\.md|readme\.txt|copyright|artisan|gulpfile\.js|package\.json|phpunit\.xml|access_log|error_log|gruntfile\.js|bower\.json|changelog\.md|console|legalnotice|license|security\.md|privacy\.md)$">
    Require all denied
</FilesMatch>
 
# Allow Lets Encrypt Domain Validation Program
<DirectoryMatch "\.well-known/acme-challenge/">
    Require all granted
</DirectoryMatch>
 
# Block .php file inside upload folder. uploads(wp), files(drupal), data(gnuboard).
<DirectoryMatch "/(uploads|default/files|data|wp-content/themes)/">
    <FilesMatch ".+\.php$">
        Require all denied
    </FilesMatch>
</DirectoryMatch>' > /etc/apache2/conf-available/deny-apache2.conf

ln -s /etc/apache2/conf-available/deny-apache2.conf /etc/apache2/conf-enabled/deny-apache2.conf

cp /root/UAAI/APM/index.html /var/www/html/
cp -f /root/UAAI/APM/index.html /usr/share/apache2/default-site/

apt-get -y install libapache2-mpm-itk

chmod 711 /home

systemctl restart apache2

apt-get -y install ssl-cert certbot python-certbot-apache

##########################################
#                                        #
#      Multi PHP 및 라이브러리 install      #
#                                        #
########################################## 

sudo apt-get install python-software-properties -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update -y

apt-get -y install php7.2 php7.2-cli php7.2-fpm php-common php7.2-mbstring php7.2-imap php7.2-json php7.2-ldap php7.2-xmlrpc php-memcache php-memcached php-geoip php7.2-curl php7.2-xml php7.2-soap php7.2-gd php7.2-mysql php7.2-opcache php7.2-bcmath php7.2-dev php-pear libgeoip-dev libapache2-mod-geoip libapache2-mod-php uwsgi-plugin-php libmcrypt-dev php7.2-bz2 php7.2-cgi php7.2-dba php7.2-enchant php7.2-gmp php7.2-snmp php7.2-zip php-imagick 

apt-get -y install php5.6 php5.6-cli php5.6-fpm php5.6-common php5.6-mbstring php5.6-imap php5.6-json php5.6-ldap php5.6-mysqlnd php5.6-xmlrpc php5.6-memcache php5.6-memcached php5.6-geoip php5.6-curl php5.6-oauth php5.6-pdo php5.6-iconv php5.6-xml php5.6-soap php5.6-gd php5.6-mysql php5.6-opcache php5.6-bcmath php5.6-dev php-pear libgeoip-dev libapache2-mod-geoip libapache2-mod-php uwsgi-plugin-php libmcrypt-dev php5.6-bz2 php5.6-cgi php5.6-dba php5.6-enchant php5.6-gmp php5.6-mcrypt php5.6-snmp php5.6-zip php5.6-imagick 

apt-get -y install php7.0 php7.0-cli php7.0-fpm php7.0-common php7.0-mbstring php7.0-imap php7.0-json php7.0-ldap php7.0-mysqlnd php7.0-xmlrpc php7.0-memcache php7.0-memcached php7.0-geoip php7.0-curl php7.0-oauth php7.0-pdo php7.0-iconv php7.0-xml php7.0-soap php7.0-gd php7.0-mysql php7.0-opcache php7.0-bcmath php7.0-dev php-pear libgeoip-dev libapache2-mod-geoip libapache2-mod-php uwsgi-plugin-php libmcrypt-dev php7.0-bz2 php7.0-cgi php7.0-dba php7.0-enchant php7.0-gmp php7.0-mcrypt php7.0-snmp php7.0-zip php7.0-imagick 

apt-get -y install php7.1 php7.1-cli php7.1-fpm php7.1-common php7.1-mbstring php7.1-imap php7.1-json php7.1-ldap php7.1-mysqlnd php7.1-xmlrpc php7.1-memcache php7.1-memcached php7.1-geoip php7.1-curl php7.1-oauth php7.1-pdo php7.1-iconv php7.1-xml php7.1-soap php7.1-gd php7.1-mysql php7.1-opcache php7.1-bcmath php7.1-dev php-pear libgeoip-dev libapache2-mod-geoip libapache2-mod-php uwsgi-plugin-php libmcrypt-dev php7.1-bz2 php7.1-cgi php7.1-dba php7.1-enchant php7.1-gmp php7.1-mcrypt php7.1-snmp php7.1-zip php7.1-imagick 

apt-get -y install php7.3 php7.3-cli php7.3-fpm php-common php7.3-mbstring php7.3-imap php7.3-json php7.3-ldap php7.3-xmlrpc php-memcache php-memcached php-geoip php7.3-curl php7.3-xml php7.3-soap php7.3-gd php7.3-mysql php7.3-opcache php7.3-bcmath php7.3-dev php-pear libgeoip-dev libapache2-mod-geoip libapache2-mod-php uwsgi-plugin-php libmcrypt-dev php7.3-bz2 php7.3-cgi php7.3-dba php7.3-enchant php7.3-gmp php7.3-snmp php7.3-zip php-imagick 

apt-get -y install php7.4 php7.4-cli php7.4-fpm php-common php7.4-mbstring php7.4-imap php7.4-json php7.4-ldap php7.4-xmlrpc php-memcache php-memcached php-geoip php7.4-curl php7.4-xml php7.4-soap php7.4-gd php7.4-mysql php7.4-opcache php7.4-bcmath php7.4-dev php-pear libgeoip-dev libapache2-mod-geoip libapache2-mod-php uwsgi-plugin-php libmcrypt-dev php7.4-bz2 php7.4-cgi php7.4-dba php7.4-enchant php7.4-gmp php7.4-snmp php7.4-zip php-imagick 

apt-get -y install php8.0 php8.0-cli php8.0-fpm php-common php8.0-mbstring php8.0-imap php8.0-ldap php8.0-xmlrpc php-memcache php-memcached php-geoip php8.0-curl php8.0-xml php8.0-soap php8.0-gd php8.0-mysql php8.0-opcache php8.0-bcmath php8.0-dev php-pear libgeoip-dev libapache2-mod-geoip libapache2-mod-php uwsgi-plugin-php libmcrypt-dev php8.0-bz2 php8.0-cgi php8.0-dba php8.0-enchant php8.0-gmp php8.0-snmp php8.0-zip php-imagick 

apt-get -y install php8.1 php8.1-cli php8.1-fpm php-common php8.1-mbstring php8.1-imap php8.1-ldap php8.1-xmlrpc php-memcache php-memcached php-geoip php8.1-curl php8.1-xml php8.1-soap php8.1-gd php8.1-mysql php8.1-opcache php8.1-bcmath php8.1-dev php-pear libgeoip-dev libapache2-mod-geoip libapache2-mod-php uwsgi-plugin-php libmcrypt-dev php8.1-bz2 php8.1-cgi php8.1-dba php8.1-enchant php8.1-gmp php8.1-snmp php8.1-zip php-imagick 

sudo a2enmod actions alias proxy_fcgi fcgid

update-alternatives --set php /usr/bin/php7.2

echo '#.php 를 제외한 나머지의 접근을 차단하자.
<FilesMatch ".+\.ph(p3|p4|p5|p7|ar|t|tml)$">
    Require all denied
</FilesMatch>' >> /etc/apache2/mods-available/php7.2.conf

echo "<VirtualHost *:80>
         # The ServerName directive sets the request scheme, hostname and port that
         # the server uses to identify itself. This is used when creating
         # redirection URLs. In the context of virtual hosts, the ServerName
         # specifies what hostname must appear in the request's Host: header to
         # match this virtual host. For the default virtual host (this file) this
         # value is not decisive as it is used as a last resort host regardless.
         # However, you must set it for any further virtual host explicitly.
         ServerName localhost

         ServerAdmin webmaster@localhost
         DocumentRoot /var/www/html

         # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
         # error, crit, alert, emerg.
         # It is also possible to configure the loglevel for particular
         # modules, e.g.
         #LogLevel info ssl:warn

         ErrorLog ${APACHE_LOG_DIR}/error.log
         CustomLog ${APACHE_LOG_DIR}/access.log combined

         # For most configuration files from conf-available/, which are
         # enabled or disabled at a global level, it is possible to
         # include a line for only one particular virtual host. For example the
         # following line enables the CGI configuration for this host only
         # after it has been globally disabled with "a2disconf".
         #Include conf-available/serve-cgi-bin.conf
         <FilesMatch \.php$>
            # Apache 2.4.10+ can proxy to unix socket
            SetHandler \"proxy:unix:/var/run/php/php7.2-fpm.sock|fcgi://localhost/\"
         </FilesMatch>
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet " > /etc/apache2/sites-available/000-default.conf

cd /root/UAAI/APM

wget http://www.maxmind.com/download/geoip/api/c/GeoIP.tar.gz
tar -xzvf GeoIP.tar.gz
cd GeoIP-1.4.8
./configure
make && make install

sed -i 's/#GeoIPDBFile/GeoIPDBFile/' /etc/apache2/mods-available/geoip.conf
sed -i 's/GeoIPEnable Off/GeoIPEnable On/' /etc/apache2/mods-available/geoip.conf

sudo a2enmod geoip
sudo a2enmod http2
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod ssl
sudo a2dismod -f autoindex


systemctl restart apache2

cp -av /etc/php/5.6/fpm/php.ini /etc/php/5.6/fpm/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/5.6/fpm/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php/5.6/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php/5.6/fpm/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php/5.6/fpm/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php/5.6/fpm/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php/5.6/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/5.6/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/5.6/fpm/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php/5.6/fpm/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php/5.6/fpm/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php/5.6/fpm/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php/5.6/fpm/php.ini 

cp -av /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/7.0/fpm/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php/7.0/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.0/fpm/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php/7.0/fpm/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php/7.0/fpm/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php/7.0/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/7.0/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/7.0/fpm/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php/7.0/fpm/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php/7.0/fpm/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php/7.0/fpm/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php/7.0/fpm/php.ini 

cp -av /etc/php/7.1/fpm/php.ini /etc/php/7.1/fpm/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/7.1/fpm/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php/7.1/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.1/fpm/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php/7.1/fpm/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php/7.1/fpm/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php/7.1/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/7.1/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/7.1/fpm/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php/7.1/fpm/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php/7.1/fpm/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php/7.1/fpm/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php/7.1/fpm/php.ini 

cp -av /etc/php/7.2/fpm/php.ini /etc/php/7.2/fpm/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/7.2/fpm/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php/7.2/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.2/fpm/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php/7.2/fpm/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php/7.2/fpm/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php/7.2/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/7.2/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/7.2/fpm/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php/7.2/fpm/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php/7.2/fpm/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php/7.2/fpm/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php/7.2/fpm/php.ini 

cp -av /etc/php/7.3/fpm/php.ini /etc/php/7.3/fpm/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/7.3/fpm/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php/7.3/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.3/fpm/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php/7.3/fpm/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php/7.3/fpm/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php/7.3/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/7.3/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/7.3/fpm/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php/7.3/fpm/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php/7.3/fpm/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php/7.3/fpm/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php/7.3/fpm/php.ini 

cp -av /etc/php/7.4/fpm/php.ini /etc/php/7.4/fpm/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/7.4/fpm/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php/7.4/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.4/fpm/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php/7.4/fpm/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php/7.4/fpm/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php/7.4/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/7.4/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/7.4/fpm/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php/7.4/fpm/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php/7.4/fpm/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php/7.4/fpm/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php/7.4/fpm/php.ini 

cp -av /etc/php/8.0/fpm/php.ini /etc/php/8.0/fpm/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/8.0/fpm/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php/8.0/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php/8.0/fpm/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php/8.0/fpm/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php/8.0/fpm/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php/8.0/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/8.0/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/8.0/fpm/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php/8.0/fpm/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php/8.0/fpm/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php/8.0/fpm/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php/8.0/fpm/php.ini 

cp -av /etc/php/8.1/fpm/php.ini /etc/php/8.1/fpm/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/8.1/fpm/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php/8.1/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php/8.1/fpm/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php/8.1/fpm/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php/8.1/fpm/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php/8.1/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/8.1/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/8.1/fpm/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php/8.1/fpm/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php/8.1/fpm/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php/8.1/fpm/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php/8.1/fpm/php.ini 

apt-get -y install php-ssh2

apt-get -y install udisks2-btrfs


mkdir /etc/skel/public_html

mkdir /etc/apache2/logs/

chmod 707 /etc/skel/public_html

chmod 700 /root/UAAI/adduser.sh

chmod 700 /root/UAAI/deluser.sh

chmod 700 /root/UAAI/restart.sh

chmod 700 /root/UAAI/clamav.sh

cp /root/UAAI/APM/skel/index.html /etc/skel/public_html/

systemctl restart apache2

echo '<?php
phpinfo();
?>' >> /var/www/html/phpinfo.php

##########################################
#                                        #
#        mariadb install & Setup         #
#                                        #
##########################################

apt-get -y install mariadb-server mariadb-client

echo "[mysql]
default-character-set = utf8mb4
 
[mysqld]
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
 
query_cache_type = ON
query_cache_limit = 1M
query_cache_size = 16M
 
sql_mode = NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
  
[client]
default-character-set = utf8mb4" > /etc/mysql/mysql.conf.d/mysql-aai.cnf

##########################################
#                                        #
#        운영 및 보안 관련 추가 설정            #
#                                        #
##########################################

cd /root/UAAI/APM

#chkrootkit 설치
apt-get -y install chkrootkit
sed -i 's/RUN_DAILY="false"/RUN_DAILY="true"/' /etc/chkrootkit.conf

#fail2ban 설치
apt-get -y install fail2ban
sed -i 's/#ignoreip/ignoreip/' /etc/fail2ban/jail.conf
systemctl restart fail2ban

#arpwatch 설치
apt-get -y install arpwatch

#clamav 설치
apt-get -y install clamav clamav-daemon

lsof /var/log/clamav/freshclam.log
pkill -15 -x freshclam
/etc/init.d/clamav-freshclam stop
freshclam
/etc/init.d/clamav-freshclam start

mkdir /virus
mkdir /backup

/etc/init.d/clamav-daemon stop

#mod_security 설치
apt-get -y install libapache2-mod-security2

cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

mv /usr/share/modsecurity-crs /usr/share/modsecurity-crs.bk
git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/share/modsecurity-crs

sed -i 's/IncludeOptional \/usr\/share\/modsecurity-crs\/owasp-crs.load/#IncludeOptional \/usr\/share\/modsecurity-crs\/owasp-crs.load/' /etc/apache2/mods-enabled/security2.conf
sed -i '/<\/IfModule>/i\        IncludeOptional \/usr\/share\/modsecurity-crs\/*.conf' /etc/apache2/mods-enabled/security2.conf
sed -i '/<\/IfModule>/i\        IncludeOptional \/usr\/share\/modsecurity-crs\/rules\/*.conf' /etc/apache2/mods-enabled/security2.conf

systemctl restart apache2

#memcached 설치
apt-get -y install memcached

#mod_expires 설정
a2enmod expires
systemctl restart apache2

echo "#mod_expires configuration" > /tmp/apache2.conf_tempfile
echo "<IfModule mod_expires.c>"   >> /tmp/apache2.conf_tempfile
echo "    ExpiresActive On"    >> /tmp/apache2.conf_tempfile
echo "    ExpiresDefault \"access plus 1 days\""    >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType text/css \"access plus 1 days\""       >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType text/javascript \"access plus 1 days\""      >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType text/x-javascript \"access plus 1 days\""        >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType application/x-javascript \"access plus 1 days\"" >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType application/javascript \"access plus 1 days\""    >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType image/jpeg \"access plus 1 days\""    >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType image/gif \"access plus 1 days\""       >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType image/png \"access plus 1 days\""      >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType image/bmp \"access plus 1 days\""        >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType image/cgm \"access plus 1 days\"" >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType image/tiff \"access plus 1 days\""       >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType audio/basic \"access plus 1 days\""      >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType audio/midi \"access plus 1 days\""        >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType audio/mpeg \"access plus 1 days\""        >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType audio/x-aiff \"access plus 1 days\""  >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType audio/x-mpegurl \"access plus 1 days\"" >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType audio/x-pn-realaudio \"access plus 1 days\""   >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType audio/x-wav \"access plus 1 days\""   >> /tmp/apache2.conf_tempfile
echo "    ExpiresByType application/x-shockwave-flash \"access plus 1 days\""   >> /tmp/apache2.conf_tempfile
echo "</IfModule>"   >> /tmp/apache2.conf_tempfile
cat /tmp/apache2.conf_tempfile > /etc/apache2/mods-available/expires.conf
rm -f /tmp/apache2.conf_tempfile

systemctl restart apache2

##########################################
#                                        #
#            Local SSL 설정               #
#                                        #
##########################################

mv /root/UAAI/APM/etc/cron.daily/backup /etc/cron.daily/
mv /root/UAAI/APM/etc/cron.daily/check_chkrootkit /etc/cron.daily/
mv /root/UAAI/APM/etc/cron.daily/letsencrypt-renew /etc/cron.daily/

chmod 700 /etc/cron.daily/backup
chmod 700 /etc/cron.daily/check_chkrootkit
chmod 700 /etc/cron.daily/letsencrypt-renew

echo "00 20 * * * /root/cron.daily/check_chkrootkit" >> /etc/crontab
echo "01 02,14 * * * /etc/cron.daily/letsencrypt-renew" >> /etc/crontab
echo "01 01 * * 7 /root/UAAI/clamav.sh" >> /etc/crontab

#openssl 로 디피-헬만 파라미터(dhparam) 키 만들기 둘중 하나 선택
#openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

#mcrypt 설치
#sudo pecl channel-update pecl.php.net
#sudo pecl install mcrypt-1.0.1

#sudo bash -c "echo extension=/usr/lib/php/20190902/mcrypt.so > /etc/php/7.2/mods-available/mcrypt.ini"
#ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/fpm/conf.d/20-mcrypt.ini
#ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/cli/conf.d/20-mcrypt.ini
#ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/cgi/conf.d/20-mcrypt.ini

#sudo bash -c "echo extension=/usr/lib/php/20190902/mcrypt.so > /etc/php/7.3/mods-available/mcrypt.ini"
#ln -s /etc/php/7.3/mods-available/mcrypt.ini /etc/php/7.3/fpm/conf.d/20-mcrypt.ini
#ln -s /etc/php/7.3/mods-available/mcrypt.ini /etc/php/7.3/cli/conf.d/20-mcrypt.ini
#ln -s /etc/php/7.3/mods-available/mcrypt.ini /etc/php/7.3/cgi/conf.d/20-mcrypt.ini

#sudo bash -c "echo extension=/usr/lib/php/20190902/mcrypt.so > /etc/php/7.4/mods-available/mcrypt.ini"
#ln -s /etc/php/7.4/mods-available/mcrypt.ini /etc/php/7.4/fpm/conf.d/20-mcrypt.ini
#ln -s /etc/php/7.4/mods-available/mcrypt.ini /etc/php/7.4/cli/conf.d/20-mcrypt.ini
#ln -s /etc/php/7.4/mods-available/mcrypt.ini /etc/php/7.4/cgi/conf.d/20-mcrypt.ini

#ioncube loader 설치 및 설정
cd /tmp && wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xfz ioncube_loaders_lin_*.gz
sudo mv /tmp/ioncube /usr/lib/php/ioncube
rm -rf /tmp/ioncube*

sed -i '/; End:/i\zend_extension = /usr/lib/php/ioncube/ioncube_loader_lin_5.6.so' /etc/php/5.6/fpm/php.ini
sed -i '/; End:/i\zend_extension = /usr/lib/php/ioncube/ioncube_loader_lin_7.0.so' /etc/php/7.0/fpm/php.ini
sed -i '/; End:/i\zend_extension = /usr/lib/php/ioncube/ioncube_loader_lin_7.1.so' /etc/php/7.1/fpm/php.ini
sed -i '/; End:/i\zend_extension = /usr/lib/php/ioncube/ioncube_loader_lin_7.2.so' /etc/php/7.2/fpm/php.ini
sed -i '/; End:/i\zend_extension = /usr/lib/php/ioncube/ioncube_loader_lin_7.3.so' /etc/php/7.3/fpm/php.ini
sed -i '/; End:/i\zend_extension = /usr/lib/php/ioncube/ioncube_loader_lin_7.4.so' /etc/php/7.4/fpm/php.ini

#중요 폴더 및 파일 링크
ln -s /etc/letsencrypt /root/UAAI/letsencrypt
ln -s /etc/apache2 /root/UAAI/apache2
ln -s /etc/mysql/conf.d/mysql.cnf /root/UAAI/mysql.cnf

systemctl restart php5.6-fpm
systemctl restart php7.0-fpm
systemctl restart php7.1-fpm
systemctl restart php7.2-fpm
systemctl restart php7.3-fpm
systemctl restart php7.4-fpm
systemctl restart php8.0-fpm
systemctl restart php8.1-fpm

systemctl enable php5.6-fpm
systemctl enable php7.0-fpm
systemctl enable php7.1-fpm
systemctl enable php7.2-fpm
systemctl enable php7.3-fpm
systemctl enable php7.4-fpm
systemctl enable php8.0-fpm
systemctl enable php8.1-fpm

cd /root/UAAI

systemctl restart apache2

/usr/bin/mysql_secure_installation

##########################################
#                                        #
#              cockpit 설치               #
#                                        #
##########################################
cd /root/UAAI

sudo apt -y install cockpit

sudo systemctl start cockpit

sh /root/UAAI/restart.sh

echo ""
echo ""
echo "축하 드립니다. APMinstaller 모든 작업이 끝났습니다."

exit 0
