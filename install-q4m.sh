#!/bin/sh
set -xe

echo -e "\e[1;32mStarting Q4M installation.\e[m"
cd /tmp/q4m-$Q4MVER
./configure --prefix=$MYSQLDIR --with-mysql=/tmp/mysql-$MYVER CFLAGS="-I$MYSQLDIR/include/mysql" CPPFLAGS="-I$MYSQLDIR/include/mysql"
make && make install

mysql -u root < support-files/install.sql
mysql -u root -e 'show plugins'
