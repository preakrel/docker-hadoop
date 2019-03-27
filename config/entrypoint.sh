#!/bin/bash


rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

: ${HADOOP_PREFIX:=/opt/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

service ssh start

hostname=$(hostname -f)
sed -i "s/HOSTNAME/localhost/" /opt/hadoop/etc/hadoop/core-site.xml

/opt/hadoop/bin/hdfs namenode -format
/opt/hadoop/sbin/start-dfs.sh
/opt/hadoop/sbin/start-yarn.sh
/opt/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver

tail -f /dev/null

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi


