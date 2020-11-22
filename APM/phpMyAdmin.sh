#!/bin/bash
 
#####################################################################################
#                                                                                   #
# * Ubuntu APMinstaller v.1.5.2                                                     #
# * Ubuntu 18.04.1-live-server                                                      #
# * Apache 2.4.X , MariaDB 10.4.X, Multi-PHP(base php7.2) setup shell script        #
# * Created Date    : 2020/04/17                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

##########################################
#                                        #
#           phpMyAdmin install           #
#                                        #
########################################## 

apt-get -y install phpmyadmin

echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
###phpmyadmin 로그인이 안되는 현상이 발생해서 주석 처리함
#sed -i 's/cookie/http/' /etc/phpmyadmin/config.inc.php

sh /root/UAAI/restart.sh

echo ""
echo ""
echo "축하 드립니다. phpMyAdmin 설치 작업이 끝났습니다."

exit 0
