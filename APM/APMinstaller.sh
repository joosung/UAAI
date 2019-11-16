#!/bin/bash
 
#####################################################################################
#                                                                                   #
# * Ubuntu APMinstaller v.0.3.9                                                     #
# * Ubuntu 18.04.1-live-server                                                      #
# * Apache 2.4.X , Mysql 5.7.X, PHP 7.2.X setup shell script                        #
# * Created Date    : 2019/2/12                                                     #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

##########################################
#                                        #
#           repositories update          #
#                                        #
########################################## 
sudo add-apt-repository ppa:ondrej/apache2

sudo apt-get install software-properties-common

sudo add-apt-repository ppa:ondrej/php

apt -y update && sudo apt -y upgrade

apt -y install git zip unzip sendmail glibc* zlib1g-dev gcc make git autoconf autogen automake pkg-config libuuid-devel

##########################################
#                                        #
#           아파치2 및 HTTP2 설치            #
#                                        #
########################################## 

# apache2 설치
apt -y install apache2

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

ufw allow 19999

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

apt -y install libapache2-mpm-itk

chmod 711 /home

systemctl restart apache2

apt -y install ssl-cert certbot python-certbot-apache

##########################################
#                                        #
#         PHP7.2 및 라이브러리 install       #
#                                        #
########################################## 

apt -y install php
apt -y install php-cli php-fpm php-common php-mbstring php-imap php-json php-ldap \
php-mysqlnd php-xmlrpc php-memcache php-memcached php-geoip libgeoip-dev libapache2-mod-geoip \
libapache2-mod-php php-pdo php-iconv php-xml php-soap php-gd php-mysql uwsgi-plugin-php  \
php-opcache php-curl php-bcmath php-oauth php-dev

pecl channel-update pecl.php.net
pecl install mcrypt-1.0.1

echo '#.php 를 제외한 나머지의 접근을 차단하자.
<FilesMatch ".+\.ph(p3|p4|p5|p7|ar|t|tml)$">
    Require all denied
</FilesMatch>' >> /etc/apache2/mods-available/php7.2.conf

cd /root/UAAI/APM

wget http://www.maxmind.com/download/geoip/api/c/GeoIP.tar.gz
tar -xzvf GeoIP.tar.gz
cd GeoIP-1.4.8
./configure
make && make install

sed -i 's/#GeoIPDBFile/GeoIPDBFile/' /etc/apache2/mods-available/geoip.conf
sed -i 's/GeoIPEnable Off/GeoIPEnable On/' /etc/apache2/mods-available/geoip.conf

a2enmod geoip
a2enmod http2
a2enmod rewrite
a2enmod headers
a2enmod ssl
a2dismod -f autoindex

systemctl restart apache2

cp -av /etc/php/7.2/apache2/php.ini /etc/php/7.2/apache2/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/7.2/apache2/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php/7.2/apache2/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.2/apache2/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php/7.2/apache2/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php/7.2/apache2/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php/7.2/apache2/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/7.2/apache2/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/7.2/apache2/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php/7.2/apache2/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php/7.2/apache2/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php/7.2/apache2/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php/7.2/apache2/php.ini 

mkdir /etc/skel/public_html

chmod 707 /etc/skel/public_html

chmod 700 /root/UAAI/adduser.sh

chmod 700 /root/UAAI/deluser.sh

chmod 700 /root/AAI/restart.sh

chmod 700 /root/UAAI/clamav.sh

cp /root/UAAI/APM/skel/index.html /etc/skel/public_html/

systemctl restart apache2

echo '<?php
phpinfo();
?>' >> /var/www/html/phpinfo.php

##########################################
#                                        #
#        mysql 5.7 install & Setup       #
#                                        #
##########################################

apt -y install mysql-server mysql-client

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
apt -y install chkrootkit
sed -i 's/RUN_DAILY="false"/RUN_DAILY="true"/' /etc/chkrootkit.conf

#fail2ban 설치
apt -y install fail2ban
sed -i 's/#ignoreip/ignoreip/' /etc/fail2ban/jail.conf
systemctl restart fail2ban

#clamav 설치
apt -y install clamav clamav-daemon

lsof /var/log/clamav/freshclam.log
pkill -15 -x freshclam
/etc/init.d/clamav-freshclam stop
freshclam
/etc/init.d/clamav-freshclam start

mkdir /virus
mkdir /backup

/etc/init.d/clamav-daemon stop

#mod_security 설치
apt -y install libapache2-mod-security2

cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

mv /usr/share/modsecurity-crs /usr/share/modsecurity-crs.bk
git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/share/modsecurity-crs

sed -i 's/IncludeOptional \/usr\/share\/modsecurity-crs\/owasp-crs.load/#IncludeOptional \/usr\/share\/modsecurity-crs\/owasp-crs.load/' /etc/apache2/mods-enabled/security2.conf
sed -i '/<\/IfModule>/i\        IncludeOptional \/usr\/share\/modsecurity-crs\/*.conf' /etc/apache2/mods-enabled/security2.conf
sed -i '/<\/IfModule>/i\        IncludeOptional \/usr\/share\/modsecurity-crs\/rules\/*.conf' /etc/apache2/mods-enabled/security2.conf

systemctl restart apache2

#memcached 설치
apt -y install memcached

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

#중요 폴더 및 파일 링크
ln -s /etc/letsencrypt /root/UAAI/letsencrypt
ln -s /etc/apache2 /root/UAAI/apache2
ln -s /etc/mysql/conf.d/mysql.cnf /root/UAAI/mysql.cnf
ln -s /etc/php/7.2/apache2/php.ini /root/UAAI/php.ini


systemctl restart apache2

/usr/bin/mysql_secure_installation

##########################################
#                                        #
#              Netdata 설치               #
#                                        #
##########################################
cd /root/UAAI

wget https://my-netdata.io/kickstart.sh

chmod 700 kickstart.sh

sh kickstart.sh

echo "Netdata 설치 완료!"

rm -rf /root/UAAI/kickstart.sh

echo ""
echo ""
echo "축하 드립니다. APMinstaller 모든 작업이 끝났습니다."

exit 0
