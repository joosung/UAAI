#!/bin/bash

/etc/init.d/clamav-daemon start 

clamscan -r /home --move=/virus

/etc/init.d/clamav-daemon stop

sh /root/UAAI/restart.sh