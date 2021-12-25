#!/bin/bash

##########################################################
# * adduser V 1.5                                        #
# * Ubuntu APMinstaller v.1.5.4 전용                      #
# * Created Date    : 2021/12/24                         #
# * Created by  : Joo Sung ( webmaster@apachezone.com )  # 
##########################################################

echo "

               [1] 사용자 계정, VHOST, DB, SSL 통합 추가하기.
               
               [2] 사용자 계정 개별 추가하기.  
               
               [3] VirtualHost 개별 추가하기.                 

               [4] Mysql 계정 개별 추가하기.                  

               [5] Let's Encrypt SSL 개별 추가하기.   
	       
"

echo -n "select Number:"
read Num

case "$Num" in


#사용자 계정, VHOST, DB, SSL 통합 추가하기.
1)
echo =======================================================
echo
echo  "< 계정 사용자 통합 추가하기>"
echo
echo  계정ID, 도메인, 계정Password 를 입력       
echo
echo =======================================================
echo 
echo -n "계정 ID 입력:"
         read id

echo -n "도메인 주소 입력:"
         read url

echo -n "서버 php 입력하세요 (5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1 중 하나만 선택 입력) :"
         read php

echo -n "계정 패스워드 입력:"
         read pass

echo -n "
        계정 ID : $id  
	패스워드 : $pass
	도메인  : $url
	php버전 : $php

-------------------------------------------------------------
        맞으면 <Enter>를 누르고 앞서 입력한 계정 패스워드를 생성 하세요.
	틀리면 No 를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
         exit
fi

#계정 ID 추가 
adduser $id

#VHOST 추가하기
echo "<VirtualHost *:80>
    ServerName $url
    ServerAlias www.$url

    DocumentRoot /home/$id/public_html

    <Directory /home/$id/public_html>
        Options FollowSymLinks MultiViews
        AllowOverride All
        require all granted
    </Directory>

    <FilesMatch \.php$>
        # Apache 2.4.10+ can proxy to unix socket
        SetHandler \"proxy:unix:/var/run/php/php$php-fpm.sock|fcgi://localhost/\"
    </FilesMatch>

    ErrorLog logs/$url-error_log
    CustomLog logs/$url-access_log common

</VirtualHost>" >> /etc/apache2/sites-available/$id.conf

ln -s /etc/apache2/sites-available/$id.conf /etc/apache2/sites-enabled/$id.conf

#계정 폴더 퍼미션 변경
chmod 701 /home/$id

# Mysql 계정 추가하기 
echo "create database $id;
GRANT ALL PRIVILEGES ON $id.* TO $id@localhost IDENTIFIED by '$pass';" > ./tmp

echo "Mysql ROOT 패스워드를 입력하세요"

mysql -u root -p mysql < ./tmp

rm -f ./tmp

#SSL 추가 하기 
certbot --apache -d $url -d www.$url

#아파치 restart
systemctl restart apache2

echo ""
echo ""
echo ""
echo "계정 및 VHOST, DB, SSL 추가 작업이 완료 되었습니다."
exit;;

 
#사용자 추가 하기 
2)
echo =======================================================
echo
echo  "< 계정 사용자 개별 추가하기>"
echo
echo  계정ID, 계정Password 를 입력       
echo
echo =======================================================
echo 
echo -n "사용자 계정 입력:"
         read id


echo -n "사용자 패스워드 입력:"
         read pass

echo -n "
        사용자 계정: $id        
        사용자패스워드: $pass

-------------------------------------------------------------
        맞으면 <Enter>를 누르고 앞서 입력한 계정 패스워드를 생성 하세요.
	틀리면 No 를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
         exit
fi

echo""
echo "호스팅 사용자를 추가합니다."

#계정 ID 추가 
adduser $id

echo ""
echo "사용자 아이디와 패스워드 입니다"
echo ""
echo ""
echo "사용자 ID: $id" 

echo "패스워드 : $pass"

echo "사용자 추가 완료!"

exit;;

# 가상호스트 추가하기
3)

echo =======================================================
echo
echo  "< 가상 호스트 개별 추가하기 >"
echo
echo  계정 도메인, 계정ID, IP는 *:80 을 입력   
echo
echo =======================================================
echo 
echo -n "url 주소를 입력하세요 :"
         read url

echo -n "계정 ID를 입력 하세요 :"
         read id

echo -n "서버 php 입력하세요 (5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1 중 하나만 선택 입력) :"
         read php

echo -n "
       
          사용자 도메인 : $url
            게정 ID   : $id
	    php 버전  : $php   

-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
         exit
fi

echo "<VirtualHost *:80>
    ServerName $url
    ServerAlias www.$url

    DocumentRoot /home/$id/public_html

    <Directory /home/$id/public_html>
        Options FollowSymLinks MultiViews
        AllowOverride All
        require all granted
    </Directory>

    <FilesMatch \.php$>
        # Apache 2.4.10+ can proxy to unix socket
        SetHandler \"proxy:unix:/var/run/php/php$php-fpm.sock|fcgi://localhost/\"
    </FilesMatch>

    ErrorLog logs/$url-error_log
    CustomLog logs/$url-access_log common

</VirtualHost>" >> /etc/apache2/sites-available/$id.conf

ln -s /etc/apache2/sites-available/$id.conf /etc/apache2/sites-enabled/$id.conf

echo "가상 호스트 추가 완료!"

#계정 폴더 퍼미션 변경
chmod 701 /home/$id

#아파치 restart
systemctl restart apache2

exit;;

# Mysql 계정 추가하기 
4)
echo =======================================================
echo
echo  "< Mysql 계정 개별 추가하기  >"
echo
echo  계정ID, MySql Password를 입력
echo
echo =======================================================
echo 
echo -n "Mysql 계정 :" 
         read id

echo -n "Mysql 패스워드 :"
         read pass
echo -n "
       
        사용자 ID : $id
        패스워드  : $pass

-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
           exit
fi

echo "create database $id;
GRANT ALL PRIVILEGES ON $id.* TO $id@localhost IDENTIFIED by '$pass';" > ./tmp

echo "
       Mysql 루트 패스워드를 입력하세요    
"

mysql -u root -p mysql < ./tmp

rm -f ./tmp


echo "DB 추가 완료!"
exit;; 



#SSL 추가 하기 
5)
echo =======================================================
echo
echo  "< Let's Encrypt SSL 개별 추가하기>"
echo
echo  계정ID, 계정Password 를 입력       
echo
echo =======================================================
echo 
echo -n "계정 ID :" 
         read id
echo -n "url 주소를 입력하세요 :"
         read url

echo -n "
        사용자 ID : $id
        사용자 도메인 : $url
-------------------------------------------------------------
        맞으면 <Enter>를 누르고 틀리면 No를 입력하세요: "
        read chk

if [ "$chk" != "" ]

then
           exit
fi

certbot --apache -d $url -d www.$url

echo 
echo 
echo "Let's Encrypt SSL 추가 완료!"
echo 
exit;;*)

esac
