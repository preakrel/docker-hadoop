# Hadoop (Single Node) with Docker from scratch.


## For impatient people.
The first time, will take few minutes downloading the image.

### To start the container (very impatient people).
```
docker run --name hadoop -it -P daocloud.io/php_ity/docker-hadoop
```
After this, you will be inside of the hadoop docker container terminal.

Basically:
- Hadoop installation folder : **/opt/hadoop**
- Hadoop tmp folder (data folder) : **/var/lib/hadoop**
- Hadoop config folder : **/opt/hadoop/etc/hadoop**

If you want to execute a hadoop example, for example:
```
/opt/hadoop/bin/hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar pi 16 100000
```

### To start the container (no so much impatient).
**Where "username", put your username :)**
```
mkdir /home/username/hadoop
docker run --name my-new-hadoop \
  -v /home/username/hadoop/logs:/opt/hadoop/logs \
  -v /home/username/hadoop/shared:/root/shared \
  -p 50070:50070 \
  -p 50075:50075 \
  -p 50060:50060 \
  -p 50030:50030 \
  -p 19888:19888 \
  -p 10033:10033 \
  -p 8032:8032 \
  -p 8030:8030 \
  -p 8088:8088 \
  -p 8033:8033 \
  -p 8042:8042 \
  -p 8188:8188 \
  -p 8047:8047 \
  -p 8788:8788 \
  -it daocloud.io/php_ity/docker-hadoop
```

Enjoy!!!
