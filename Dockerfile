FROM centos:centos6
MAINTAINER Motonori Iwata <gootonori+docker@gmail.com>

ENV MYVER 5.6.20
ENV Q4MVER 0.9.13
ENV HSVER 1.1.1
ENV MYSQLDIR /usr/local/mysql
ENV TZ Asia/Tokyo

RUN echo "ZONE=\"$TZ\"" > /etc/sysconfig/clock

# Upgrade to latest version
RUN rpm -Uvh http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    yum -y upgrade

ENV LANG en_US.UTF-8

# install mysql
RUN yum install -y curl wget tar ntp && yum -y clean all
RUN rm -f /etc/localtime && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

RUN cd /tmp && curl -O http://mysql.mirrors.pair.com/Downloads/MySQL-5.6/mysql-$MYVER.tar.gz && tar zxf mysql-$MYVER.tar.gz && rm mysql-$MYVER.tar.gz
RUN cd /tmp && curl -O http://q4m.kazuhooku.com/dist/q4m-$Q4MVER.tar.gz && tar zxf q4m-$Q4MVER.tar.gz && rm q4m-$Q4MVER.tar.gz
RUN cd /tmp && wget https://github.com/DeNA/HandlerSocket-Plugin-for-MySQL/archive/$HSVER.tar.gz && tar zxf $HSVER.tar.gz && rm $HSVER.tar.gz

# to compile MySQL
RUN yum install -y gcc gcc-c++ ncurses-devel cmake libedit-devel perl && yum -y clean all

ADD ./install-mysql.sh /install-mysql.sh
ADD ./install-q4m.sh /install-q4m.sh
ADD ./install-handlersocket.sh /install-handlersocket.sh
RUN chmod +x /*.sh

RUN /install-mysql.sh
ENV PATH $MYSQLDIR/bin:$PATH

# to compile HandlerSocket
RUN yum install -y libedit libtool which && yum -y clean all
# メモリやプロセスの状態変化はRUNをまたげないので&&でつなぐ必要がある
RUN mysqld_safe --user=mysql & /install-q4m.sh && /install-handlersocket.sh && mysql -u root -h localhost --port 3306 -e "grant all privileges on *.* to root@'%';"

ADD ./my.cnf /etc/my.cnf

EXPOSE 3306
#ENTRYPOINT ["/usr/local/mysql/bin/mysqld_safe"]
#CMD ["--user=mysql"]
CMD ["/usr/local/mysql/bin/mysqld_safe", "--user=mysql"]
