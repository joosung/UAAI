UAAI - APM AUTO INSTALL V.24
<pre>
UBUNTU 24.04.1 버전에서 작업되어 졌습니다.
쉽고 빠른 설치, 운영, 업데이트까지 고려한 설계
쉬운 업데이트 지원. (공식+인기 저장소를 사용하여 apt-get 만으로 업데이트 완료)
사용자 생성,삭제,백업 스크립트 사용으로 시스템 계정, 디비 계정 자동 생성 지원
Let's Encrypt - 무료 SSL 인증서 발급 및 갱신 지원
모니터링 툴 - cockpit 지원
</pre>


UAAI GIT 설치 방법

SSH와 SFTP 는 필히 root 권한으로 접속 합니다.
아래 명령어를 사용해서 설치를 진행 합니다. 설치 화면에서 'y' 만 누르면 설치가 진행 됩니다.
<pre>
apt -y install git \
&& cd /root/ \
&& git clone https://github.com/joosung/UAAI.git \
&& cd UAAI \
&& sh install.sh
</pre>

AAI 다운로드 설치 방법

1. SSH와 SFTP 는 필히 root 권한으로 접속 합니다.
2. UAAI-master 압축 파일을 다운로드 받으시고 압축을 해제 후 UAAI 폴더로 변경 후 자신의 서버 /root 폴더에 업로드한다.
3. Shell(터미널)에서 /root/UAAI 폴더내의 install.sh 파일의 퍼미션을 chmod 700 install.sh 로 해당 파일의 퍼미션을 700 으로 수정한다.
4. ./install.sh 입력후 엔터를 치고 설치를 진행 하시면 됩니다.


UAAI  주요 명령

1. adduser.sh
   사용자 계정 추가, VirtualHost 추가, Mysql 계정 추가, Let's Encrypt SSL 추가 를 한번에 또는 개별적으로 진행 할 수 있습니다.

2. deluser.sh
   사용자 계정 삭제, VirtualHost 삭제, Mysql 계정 삭제, Let's Encrypt SSL 삭제 를 한번에 또는 개별적으로 진행 할 수 있습니다.

3. /etc/cron.daily/backup 파일을 에디터로 열고 '패스워드' 를 찾아서 mysql root 패스워드로 교체 합니다.

4. 스푸핑 에 관련된 메일을 받고 싶을땐 /etc/sysconfig/arpwatch 파일을 열어서 아래와 같이 수정 하세요.
   OPTIonS="-u pcap -e '메일주소' -s '보내는이(Arpwatch)' -n 'ㅣ자신의IP/24'"

5. cockpit 지원으로 인하여 port 9090 를 서버 방화벽에서 열어 주셔야 합니다.

6. clamav.sh Crontab 적용으로 매주 일요일 01시01분에 바이러스 체크를 진행하고 바이러스가 체크되면 자동으로 /virus 폴더로 이동 됩니다.

7. 사용중인 php 버전을 다른 버전으로 교체 할 경우에는 /etc/apache2/sites-available/계정명-le-ssl.conf(또는 계정명.conf) 파일을 에디터로 열고 
   SetHandler "proxy:unix:/var/run/php/php7.2-fpm.sock|fcgi://localhost/" 이부분을 찾아서 php7.2 부분의 뒷자리 두 숫자를 수정해 주시면 됩니다.
   예 : PHP 5.6 사용시 5.6, PHP 7.0 사용시 7.0, PHP 8.4 사용시 8.4 등으로 수정 후 UAAI 폴더내의 ./restart.sh 를 진행해 주시면 됩니다. 

8. phpmyadmin wget 설치로 변경하고 http://ip/phpmyadmin 으로 호출하여 사용 되며, 버추얼 호스트 수정 또는 추가를 이용해 서브 도메인으로 사용 하실 수 있습니다.


그외 소소한(?) 튜닝이나 설정은 구글 검색을 또는 아파치존 QnA 를 통하여 질문 하시면서 자신이 사용하기 좋은 환경을 만들어 가시면 됩니다.

UAAI 설치 및 계정 생성과 삭제 방법을 아파치존에서 동영상으로 안내 드리며, 궁금한점 또는 문의사항은 아파치존 QnA를 이용해 주시기 바랍니다.

https://apachezone.com

<pre>
APM 설치 버전은 아래와 같습니다.

apache2 2.4.x
php (base php7.2) 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4
mariadb 10.11.x
ionCube PHP Loader
Zend OPcache
Let's Encrypt
chkrootkit
clamav
arpwatch
fail2ban
mod_evasive
mod_security
mod_security_crs
memcache
memcached
mod_expires
ImageMagick 
GeoIP
cockpit
phpmyadmin 설치 수정
사용지 계정 백업 스크립트
사용자 계정 생성 스크립트
사용자 계정 삭제 스크립트 등...... 그외 필요한 라이브러리도 같이 설치가 됩니다.
</pre>

**해당 버전은 해당 APM 및 라이브러리 업데이트에 따라 달라 질 수 있습니다.
