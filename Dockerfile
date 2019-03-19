FROM ubuntu:16.04
MAINTAINER PHP Hoo <1396981439@qq.com>

USER root
WORKDIR /root

#环境变量
ENV HADOOP_VERSION=2.8.5 JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre HADOOP_HOME=/opt/hadoop  PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:${HBASE_HOME}/bin WEB=http://mirrors.hust.edu.cn/apache CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop WEB=http://mirrors.hust.edu.cn/apache

COPY config/* /opt/config/

# Install all dependencies
RUN apt-get -y update --fix-missing \
    && apt-get install --no-install-recommends -y wget ssh rsync openjdk-8-jdk ant gnupg maven xmlstarlet net-tools telnetd curl python htop python3 openssh-server openssh-client vim \
    \
    && cd /opt \
    # Download hadoop.
    && wget -q -O hadoop-${HADOOP_VERSION}.tar.gz $WEB/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -zxf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} hadoop \
    && rm -rf hadoop-${HADOOP_VERSION}.tar.gz \
    && rm -rf /opt/hadoop/share/doc \
    \
    # Install ssh key
    # &&  ssh-keygen -q -t dsa -P '' -f /root/.ssh/id_dsa \
    # && cat /root/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys \
    \
    # Copy Hadoop config files
    && mv /opt/config/config /root/.ssh/config \
    && mv /opt/config/hadoop-env.sh /opt/hadoop/etc/hadoop/ \
    && mv /opt/config/core-site.xml /opt/hadoop/etc/hadoop/ \
    && mv /opt/config/hdfs-site.xml /opt/hadoop/etc/hadoop/ \
    && mv /opt/config/mapred-site.xml /opt/hadoop/etc/hadoop/ \
    && mv /opt/config/yarn-site.xml /opt/hadoop/etc/hadoop/ \
    && mkdir -pv /var/lib/hadoop  \
    && chmod 777 -R /var/lib/hadoop \
    \
    # Format hdfs
    && /opt/hadoop/bin/hdfs namenode -format \
    \
    # Copy the entry point shell
    && mv /opt/config/entrypoint.sh / \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf  /var/tmp/* /tmp/* \
    && chmod 777 -R /opt && chmod 777 /entrypoint.sh


EXPOSE 8020 8042 8088 9000 10020 19888 50010 50020 50070 50075 50090

################## Entry point
CMD ["/entrypoint.sh"]