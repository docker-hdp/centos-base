FROM centos:6.8
MAINTAINER Arturo Bayo <arturo.bayo@gmail.com>
USER root

# Removing cached packages, headers and fixing possible RPM database errors (/var/lib/rpm)
RUN yum clean all;
RUN rpm --rebuilddb;

# Installing Linux commands and utils
RUN yum install -y curl wget scp unzip tar sudo ntp
RUN yum update -y

# Configure NTP
RUN chkconfig ntpd on && /etc/init.d/ntpd start

# Disable IPTables
RUN chkconfig iptables off && service iptables stop

# Java Development Kit (JDK) 1.7.0_71 & Configuring Java Path Variables
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie' && rpm -i jdk-8u121-linux-x64.rpm && rm jdk-8u121-linux-x64.rpm
ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# Adding HDP repository to YUM Repository
COPY files/hdp.repo /etc/yum.repos.d/.
RUN yum makecache

# Add hadoop group
ENV HADOOP_GROUP hadoop
RUN groupadd $HADOOP_GROUP

# Set ENV for current HDP stack version
ENV HDP_VERSION 2.5.3.0-37

# Creating run and bin folders to automatize the entrypoint dockerfile images executions
RUN mkdir /opt/bin && mkdir /opt/run
COPY files/run_all.sh /opt/bin/
RUN chmod +x /opt/bin/run_all.sh