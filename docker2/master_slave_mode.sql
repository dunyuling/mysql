#在线将基于日志的复制变更为基于事务的复制
#1.先决条件
#1).集群中所有服务器的版本均高于5.7.6
#2).集群中所有服务器gtid_mode都设为off
select @@global.gtid_mode;
#2.处理步骤
#1).对于主从
set @@global.enforce_gtid_consistency=warn;
set @@global.enforce_gtid_consistency=on;
set @@global.gtid_mode=off_permissive;
set @@global.gtid_mode=on_permissive;
show status like 'on_going_anonymous_transaction_count';#如果为空,则可进行下一步
set @@global.gtid_mode=on;
#2)对于从
stop slave;
change master to mater_auto_position=1;
start slave;


#在线将基于事务的复制变更为基于日志的复制
#1.先决条件
#1).集群中所有服务器的版本均高于5.7.6
#2).集群中所有服务器gtid_mode都设为on
select @@global.gtid_mode;
#2.处理步骤
#1)对于从
stop slave;
change master to mater_auto_position=0,master_log_file='file',master_log_pos=position;
start slave;
#2).对于主从
set @@global.gtid_mode=on_permissive;
set @@global.gtid_mode=off_permissive;
select @@global.gtid_owned;#如果为空,则可进行下一步
set @@global.gtid_mode=off;
set @@global.enforce_gtid_consistency=off;