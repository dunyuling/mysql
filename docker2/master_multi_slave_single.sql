#配置专有网路:
docker network create --driver bridge --subnet 172.25.0.0/16 mysql_net

#以UTF-8字符集方式进入相应容器
docker exec -it container-name env LANG=C.UTF-8 bash

#进入master,slave
mysql -uroot -pmysql

#master:
#===开放所有ip 为repl
-- CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
-- revoke all on *.* from 'repl'@'%'; 
-- GRANT REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO 'repl'@'%'; #mysql5.7之前
-- CREATE USER 'repl'@'%' IDENTIFIED BY '123456'
CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
grant all on *.* to 'repl'@'%';
flush privileges;
show master status;
show grants for 'repl'@'%';	

#master:
#===开放所有ip 为repl
CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
grant all on *.* to 'repl'@'%';
flush privileges;
show master status;
show grants for 'repl'@'%';	

#==========
-- slave:
# 通过repl用户实现主从复制,未能成功
stop slave;
reset slave all;
CHANGE MASTER TO
         MASTER_HOST='172.19.0.4',
         MASTER_PORT=3306, 
         MASTER_USER='repl',
         MASTER_PASSWORD='123456',
         MASTER_LOG_FILE='replicas-mysql-bin.000023',
         MASTER_LOG_POS=195
         for channel 'master';
CHANGE MASTER TO
         MASTER_HOST='172.19.0.5',
         MASTER_PORT=3306, 
         MASTER_USER='repl',
         MASTER_PASSWORD='123456',
         MASTER_LOG_FILE='replicas-mysql-bin.000003',
         MASTER_LOG_POS=822
         for channel 'master2';         
start slave;
show slave status \G

#设置主动延迟时间
change master to master_delay=0;
#对应performance_schema.replication_applier_configuration表
select * from replication_applier_configuration;
#+--------------+---------------+
#| CHANNEL_NAME | DESIRED_DELAY |
#+--------------+---------------+
#|              |             0 |
#+--------------+---------------+