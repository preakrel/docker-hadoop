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
    && mv /opt/config/ssh_config  /root/.ssh/ \
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
    && chmod 777 -R /opt && chmod 777 /entrypoint.sh \
    && mkdir /root/shared && chmod a+rwX /root/shared

EXPOSE 2181 9000 21 50070 50470 50075 50475 50010 50020 50090 50090 50100 50105 8485 8480 8481 50060 50030 19888 10033 10020 8032 8030 8088 8090 8031 8033 8040 8042 10200 8188 8190 8047 8788 8046 8045 22

################### Expose volumes
VOLUME ["/opt/hadoop/logs", "/root/shared"]

################## Entry point
CMD ["/entrypoint.sh"]