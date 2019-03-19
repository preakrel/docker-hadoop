#!/usr/bin/env bash

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
export PATH="$PATH:/opt/hadoop/sbin:/opt/hadoop/bin"
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop

if [ $# -gt 0 ]; then
    exec $@
else
    if ! [ -f /root/.ssh/authorized_keys ]; then
        ssh-keygen -t rsa -b 1024 -f /root/.ssh/id_rsa -N ""
        cp -v /root/.ssh/{id_rsa.pub,authorized_keys}
        chmod -v 0400 /root/.ssh/authorized_keys
    fi

    if ! [ -f /etc/ssh/ssh_host_rsa_key ]; then
        /usr/sbin/sshd-keygen || :
    fi

    if ! pgrep -x sshd &>/dev/null; then
        /usr/sbin/sshd
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

    /opt/hadoop/sbin/start-dfs.sh
    /opt/hadoop/sbin/start-yarn.sh
    tail -f /dev/null
    /opt/hadoop/sbin/stop-yarn.sh
    /opt/hadoop/sbin/stop-dfs.sh
fi
