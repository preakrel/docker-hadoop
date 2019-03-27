#!/usr/bin/env bash

CORE_SITE="/opt/hadoop/etc/hadoop/core-site.xml"

addConfig () {

    if [ $# -ne 3 ]; then
        echo "There should be 3 arguments to addConfig: <file-to-modify.xml>, <property>, <value>"
        echo "Given: $@"
        exit 1
    fi

    xmlstarlet ed -L -s "/configuration" -t elem -n propertyTMP -v "" \
     -s "/configuration/propertyTMP" -t elem -n name -v $2 \
     -s "/configuration/propertyTMP" -t elem -n value -v $3 \
     -r "/configuration/propertyTMP" -v "property" \
     $1
}
addConfig $CORE_SITE "dfs.permissions" "false"

# export HADOOP_USER_NAME=root

rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

service ssh start

# hostname=$(hostname -f)
sed -i "s/localhost/hadoop/" /opt/hadoop/etc/hadoop/core-site.xml

if [ ! -d "/var/lib/hadoop/dfs/" ];then
    /opt/hadoop/bin/hdfs namenode -format
else
    echo "文件夹已经存在"
fi

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


