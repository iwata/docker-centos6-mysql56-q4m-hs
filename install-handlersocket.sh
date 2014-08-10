#!/bin/sh
set -xe

echo -e "\e[1;32mStarting HandlerSocket installation.\e[m"
cd /tmp/HandlerSocket-Plugin-for-MySQL-$HSVER
./autogen.sh
./configure --with-mysql-source=/tmp/mysql-$MYVER --with-mysql-bindir=$MYSQLDIR/bin --with-mysql-plugindir=$MYSQLDIR/lib/mysql/plugin
make && make install
mysql -u root -e "install plugin handlersocket soname 'handlersocket.so'"
mysql -u root -e 'show plugins'
