#!/bin/bash
 
#####################################################################################
#                                                                                   #
# * Ubuntu with AAI                                                                 #
# * Ubuntu 20.04.5-live-server                                                      #
# * Apache 2.4.X , MariaDB 10.11.X, Multi-PHP(base php8.2) setup shell script        #
# * Created Date    : 2025/01/01                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

##########################################
#                                        #
#           phpMyAdmin install           #
#                                        #
########################################## 



apt-get install unzip

cd /var/www/html

wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
unzip phpMyAdmin-5.2.1-all-languages.zip
mv phpMyAdmin-5.2.1-all-languages phpmyadmin
rm phpMyAdmin-5.2.1-all-languages.zip

cd phpmyadmin
cp -av config.sample.inc.php config.inc.php

sudo mkdir /var/www/html/phpmyadmin/tmp/
sudo chmod 777 /var/www/html/phpmyadmin/tmp/

# 쿠키 암호화에 사용되는 키 생성
BLOWFISH_SECRET=$(< /dev/urandom tr -dc 'A-Za-z0-9!@#' | head -c 32)
sed -i "s/\$cfg\['blowfish_secret'\] = '[^']*'/\$cfg\['blowfish_secret'\] = '${BLOWFISH_SECRET}'/g" config.inc.php

echo "\$cfg['TempDir'] = '/var/www/html/phpmyadmin/tmp/';" >> config.inc.php

sh /root/UAAI/restart.sh

echo ""
echo ""
echo "축하 드립니다. phpMyAdmin 설치 작업이 끝났습니다."

exit 0