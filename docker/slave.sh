docker create \
   --privileged=true \
   --name mysql-slave \
   -v /home/liux/mysql/docker/data/slave:/var/lib/mysql \
   -v /home/liux/mysql/docker/conf/slave/my.cnf:/etc/mysql/my.cnf \
   -v /home/liux/mysql/docker/mysql-files/slave:/var/lib/mysql-files \
   -e MYSQL_ROOT_PASSWORD=mysql \
   --net mysql_net \
   --ip 172.25.0.2 \
   -p 3308:3306 mysql

