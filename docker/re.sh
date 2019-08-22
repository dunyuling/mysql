#/bin/bash
docker rm -f mysql-master mysql-slave
sudo rm -fr data/master data/slave
mkdir data/master data/slave
./master.sh
./slave.sh
docker start mysql-master
docker start mysql-slave
docker ps
