#!/usr/bin/env bash
CORE_SITE="/opt/hadoop/etc/hadoop/core-site.xml"
HDFS_SITE="/opt/hadoop/etc/hadoop/hdfs-site.xml"

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


addConfig $CORE_SITE "fs.default.name" "hdfs://localhost:9000"
addConfig $HDFS_SITE "dfs.http.address" "0.0.0.0:50070"


export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
export PATH="$PATH:/opt/hadoop/sbin:/opt/hadoop/bin"
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
# chmod 600 /root/.ssh/config
# chown root /root/.ssh/config

rm -rf /root/.ssh/id_rsa.pub,/root/.ssh/authorized_keys,/root/.ssh/id_rsa

if ! [ -f /root/.ssh/authorized_keys ]; then
    ssh-keygen -t rsa -b 1024 -f /root/.ssh/id_rsa -N ""
    cp -v /root/.ssh/{id_rsa.pub,authorized_keys}
    chmod -v 0400 /root/.ssh/authorized_keys
fi

# if ! [ -f /etc/ssh/ssh_host_rsa_key ]; then
#     /usr/sbin/sshd-keygen || :
# fi

if ! pgrep -x sshd &>/dev/null; then
    service ssh start
fi
echo
SECONDS=0
while true; do
    if ssh-keyscan localhost 2>&1 | grep -q OpenSSH; then
        echo "SSH is ready to rock"
        break
    fi
    if [ "$SECONDS" -gt 20 ]; then
        echo "FAILED: SSH failed to come up after 20 secs"
        exit 1
    fi
    echo "waiting for SSH to come up"
    sleep 1
done
echo
if ! [ -f /root/.ssh/known_hosts ]; then
    ssh-keyscan localhost || :
    ssh-keyscan 0.0.0.0   || :
fi | tee -a /root/.ssh/known_hosts


hostname=$(hostname -f)
if ! grep -q "$hostname" /root/.ssh/known_hosts; then
    ssh-keyscan $hostname || :
fi | tee -a /root/.ssh/known_hosts

/opt/hadoop/sbin/start-all.sh
while true; do sleep 1; done
