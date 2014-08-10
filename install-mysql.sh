#!/bin/sh
set -xe

groupadd mysql
useradd -r -g mysql mysql

echo -e "\e[1;32mStarting MySQL5.6 installation.\e[m"
mysql-build -v $MYVER $MYSQLDIR q4m-$Q4MVER,handlersocket-$HSVER

rm -r /usr/local/mysql-build/build/mysql-$MYVER
rm /usr/local/mysql-build/dists/*

cd $MYSQLDIR

chown -R mysql:mysql ./
./scripts/mysql_install_db --user=mysql
chown -R root .
chown -R mysql data

cp my.cnf /etc/my.cnf

cp support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
service mysql start

./bin/mysql -uroot -e "grant all privileges on *.* to root@'%'"
./bin/mysql -uroot < support-files/install-q4m.sql
./bin/mysql -uroot -e "install plugin handlersocket soname 'handlersocket.so'"
./bin/mysql -uroot -e 'show plugins'
