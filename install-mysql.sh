#!/bin/sh
set -xe

groupadd mysql
useradd -r -g mysql mysql

echo -e "\e[1;32mStarting MySQL5.6 installation.\e[m"
cd /tmp/mysql-$MYVER

cmake . \
      -DCMAKE_INSTALL_PREFIX=$MYSQLDIR \
      -DCMAKE_FIND_FRAMEWORK=LAST \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      -DMYSQL_DATADIR=$MYSQLDIR/data/mysql \
      -DDEFAULT_CHARSET=utf8 \
      -DDEFAULT_COLLATION=utf8_general_ci \
      -DSYSCONFDIR=/etc \
      -DWITH_EDITLINE=system \
      -DENABLED_LOCAL_INFILE=1

make
make install

cd $MYSQLDIR
chown -R mysql:mysql $MYSQLDIR
./scripts/mysql_install_db --user=mysql
chown -R root .
chown -R mysql data

cp my.cnf /etc/my.cnf
