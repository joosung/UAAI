#!/bin/bash

systemctl restart php5.6-fpm
systemctl restart php7.0-fpm
systemctl restart php7.1-fpm
systemctl restart php7.2-fpm
systemctl restart php7.3-fpm
systemctl restart php7.4-fpm
systemctl restart php8.0-fpm
systemctl restart php8.1-fpm

systemctl restart apache2
