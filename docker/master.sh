docker create --privileged=true \
   --name mysql-master \
   -v /home/liux/mysql/docker/data/master:/var/lib/mysql \
   -v /home/liux/mysql/docker/conf/master/my.cnf:/etc/mysql/my.cnf \
   -v /home/liux/mysql/docker/mysql-files/master:/var/lib/mysql-files \
   -e MYSQL_ROOT_PASSWORD=mysql \
   --net mysql_net \
   --ip 172.25.0.3 \
   -p 3307:3306 mysql

