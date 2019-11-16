#!/usr/bin/env bash

#####################################################################################
#                                                                                   #
# * Ubuntu APMinstaller v.0.3.9                                                     #
# * Ubuntu 18.04.1-live-server                                                      #
# * Apache 2.4.X , Mysql 5.7.X, PHP 7.2.X setup shell script                        #
# * Created Date    : 2019/11/15                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

echo "
 =======================================================

               < UAAI 설치 하기>

 =======================================================
"
echo "설치 하시겠습니까? 'Y' or 'N'"
read YN
YN=`echo $YN | tr "a-z" "A-Z"`
 
if [ "$YN" != "Y" ]
then
    echo "설치 중단."
    exit
fi

echo""
echo "설치를 시작 합니다."

cd /root/UAAI/APM

chmod 700 APMinstaller.sh

chmod 700 /root/UAAI/adduser.sh

chmod 700 /root/UAAI/deluser.sh

#chmod 700 /root/UAAI/restart.sh

sh APMinstaller.sh

cd /root/UAAI

#설치 파일 삭제
rm -rf /root/UAAI/APM

echo ""
echo ""
echo "UAAI 설치 완료!"
echo ""
rm -rf /root/UAAI/install.sh
exit;

esac
