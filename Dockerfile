FROM ubuntu:16.04
MAINTAINER PHP

USER root
WORKDIR /root

#环境变量
ENV HADOOP_VERSION=2.8.3
ENV JAVA_HOME=/opt/java_jdk
ENV JRE_HOME=$JAVA_HOME/jre
ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV WEB=http://archive.apache.org/dist
ENV CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

COPY config/* /opt/config/

# Install all dependencies
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list \
    && apt-get -y update --fix-missing \
    && apt-get install --no-install-recommends -y -q apt-utils iputils-ping wget ssh rsync ant gnupg maven xmlstarlet net-tools telnetd curl python htop python3 openssh-server openssh-client vim sudo \
    && apt-get clean  \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa \
    && cd /opt \
    && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" -P /opt "https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz" \
    && mv jdk-8u201-linux-x64.tar.gz jdk-8u201-linux-x64.tar && tar -zxvf jdk-8u201-linux-x64.tar && mv jdk1.8.0_201 java_jdk && rm -rf jdk-8u201-linux-x64.tar \
    \
    # Download hadoop.
    && wget -q -O hadoop-${HADOOP_VERSION}.tar.gz $WEB/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -zxf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} hadoop \
    && rm -rf hadoop-${HADOOP_VERSION}.tar.gz \
    && rm -rf /opt/hadoop/share/doc \
    \
    # config
    && mv /opt/config/hadoop-env.sh /opt/hadoop/etc/hadoop/ \
    && mv /opt/config/core-site.xml /opt/hadoop/etc/hadoop/ \
    && mv /opt/config/hdfs-site.xml /opt/hadoop/etc/hadoop/ \
    && mv /opt/config/mapred-site.xml /opt/hadoop/etc/hadoop/ \
    && mv /opt/config/yarn-site.xml /opt/hadoop/etc/hadoop/ \
    && mkdir -pv /root/.ssh && mv /opt/config/ssh_config /root/.ssh/config && chmod 600 /root/.ssh/config && chown root:root /root/.ssh/config \
    && mkdir -pv /var/lib/hadoop  \
    && chmod 777 -R /var/lib/hadoop \
    \
    # Copy the entry point shell
    && mv /opt/config/entrypoint.sh / \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf  /var/tmp/* /tmp/* \
    && chmod 777 -R /opt && chmod 777 /entrypoint.sh \
    && sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config \
    && echo "UsePAM no" >> /etc/ssh/sshd_config \
    && echo "Port 2122" >> /etc/ssh/sshd_config

EXPOSE 8020 8042 8088 9000 10020 19888 50010 50020 50070 50075 50090 8030 8031 8032 8033 8040 49707 2122 22
################## Entry point
CMD ["/entrypoint.sh"]