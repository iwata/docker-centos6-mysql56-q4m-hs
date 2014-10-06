FROM centos:centos6
MAINTAINER Motonori Iwata <gootonori+docker@gmail.com>

ENV MYVER 5.6.19
ENV Q4MVER 0.9.14
ENV HSVER 1.1.1
ENV MYSQLDIR /usr/local/mysql
ENV TZ Asia/Tokyo

RUN echo "ZONE=\"$TZ\"" > /etc/sysconfig/clock

# Upgrade to latest version
RUN rpm -Uvh http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    yum -y upgrade

RUN yum install -y curl wget tar ntp unzip && yum -y clean all
RUN rm -f /etc/localtime && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

# install mysql-build
RUN cd /tmp && wget https://github.com/kamipo/mysql-build/archive/master.zip && unzip master.zip && mv mysql-build-master /usr/local/mysql-build && rm master.zip
ENV PATH /usr/local/mysql-build/bin:$PATH

# to compile MySQL
RUN yum install -y gcc gcc-c++ ncurses-devel cmake libedit-devel \
                   libaio-devel perl libedit libtool which && \
    yum -y clean all

COPY ./install-mysql.sh /install-mysql.sh
RUN chmod +x /*.sh

RUN /install-mysql.sh
ENV PATH $MYSQLDIR/bin:$PATH

COPY ./my.cnf /etc/my.cnf

ENV LANG en_US.UTF-8
EXPOSE 3306
#ENTRYPOINT ["/usr/local/mysql/bin/mysqld_safe"]
#CMD ["--user=mysql"]
CMD ["/usr/local/mysql/bin/mysqld_safe", "--user=mysql"]
