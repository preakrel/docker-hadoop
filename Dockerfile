FROM ubuntu:16.04
MAINTAINER PHP
USER root
WORKDIR /root
#环境变量
ENV HADOOP_VERSION=2.8.3
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV WEB=http://mirrors.hust.edu.cn/apache
ENV CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
COPY config/* /opt/config/
# Install all dependencies
RUN apt-get -y update && apt-get -y upgrade \
    && apt-get install --no-install-recommends -y wget ssh rsync openjdk-8-jdk openjdk-8-jre ant gnupg maven xmlstarlet net-tools telnetd curl python htop python3 openssh-server openssh-client vim sudo \
    && apt-get clean  \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa \
    && cd /opt \
    # Download hadoop.
    && wget -q -O hadoop-${HADOOP_VERSION}.tar.gz $WEB/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -zxf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} hadoop \
    && rm -rf hadoop-${HADOOP_VERSION}.tar.gz \
    && rm -rf /opt/hadoop/share/doc \
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
# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122 22
################## Entry point
CMD ["/entrypoint.sh"]