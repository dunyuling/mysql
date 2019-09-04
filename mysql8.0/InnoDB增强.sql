#1.集成数据字典
#MySQL8.0删除了之前版本的元数据文件,例如.frm,.opt等
#将系统表(mysql)和数据字典表全部改为InnoDB存储引擎
#支持原子DDL子句
#简化了INFORMATION_SCHEMA的实现,提高了访问性能
#提供了序列化字典信息(SDI)的支持,以及ibd2sdi工具.
#数据字典使用上的差异,例如innodb_read_only影响所有的存储引擎;数据字典表不可见,不能直接查询和修改.

#2.原子DDL操作 
#MySQL8.0开始支持DDL操作,其中与表相关的原子DDL只支持InnoDB存储引擎
#一个原子DDL操作内容包括:更新数据字典,存储引擎层的操作,在binlog中记录DDL操作
#支持与表相关的DDL:数据库,表空间,表,索引的create,alter,drop以及truncate table
#支持其它的DDL:存储过程,触发器,视图,UDF的CREATE,DROP,ALTER子句
#支持账户管理相关的DDL:用户和角色的(CREATE,ALTER,DROP以及适用的RENAME),以及GRANT和REVOKE语句

#3.自增列持久化
#MySQL5.7以及早起版本,InnoDB自增列计数器(AUTO_INCREMENT)的值只存储在内存中.
#MySQL8.0每次变化时将自增计数器的最大值写入redo log,同时在每次检查点将其写入引擎私有的系统表
#解决了长期以来的自增字段值可能重复的bug
#MySQL8.0: innodb_autoinc_lock_mode=2,不保证主从复制顺序,提高并发(基于行复制)
#MySQL5.7: innodb_autoinc_lock_mode=1,保证主从复制的顺序(基于语句复制)


#4.死锁检查控制
#MySQL8.0(MySQL5.7.15)增加了一个新的动态变量,用于控制系统是否执行InnoDB死锁检查
innodb_deadlock_detect
innodb_lock_wait_timeout
#对于高并发的系统,禁用死锁检查来提高并发性能
create table tt(id int primary key AUTO_INCREMENT);
insert into tt values(),(),();	
#(1)验证innodb_deadlock_detect=on
#开启两个终端
#终端1
start transaction;
select * from tt for share;
#终端2
start transaction;
delete from tt where id = 3;
#终端1
delete from tt where id = 3; #执行成功
#终端2: ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
#(2)验证 innodb_deadlock_detect=off,innodb_lock_wait_timeout=3;
#终端1
start transaction;
select * from tt for share;
#终端2
start transaction;
delete from tt where id = 3;
#终端1
delete from tt where id = 3; #执行成功
#终端2: ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction

#5.锁定语句选项
#select...for share和select...for update支持NOWAIT,SKIP LOCKED选项
#NOWAIT,如果请求的行被其它事务锁定,语句立即返回
#SKIP LOCKED,从返回的结果集中移除被锁定的行
#对于语句级别的复制,使用NOWAIT或这SKIP LOCKED选项不能保证主从一致,应避免使用
create table tt(id int primary key AUTO_INCREMENT);
insert into tt values(),(),();	
#(1)开启两个终端
#终端1
start transaction;
update tt set id = 4 where id = 1;
#终端2
start transaction;
没有nowait和skip locked: select * from tt where id = 1 for update;
#ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
nowait: select * from tt where id = 1 for update nowait;
#ERROR 3572 (HY000): Statement aborted because lock(s) could not be acquired immediately and NOWAIT is set.
skip locked: select * from tt for update skip locked;
#+----+
#| id |
#+----+
#|  2 |
#|  3 |
#+----+

#6.其他改进功能
#支持快速DDL,ALTER TABLE...ALGORITHM=INSTANT;
#InnoDB 临时表使用共享的临时表空间 ibtmp1.
#新增静态变量 innodb_dedicated_server,自动配置InnoDB内存参数:innodb_buffer_pool_size/innodb_log_file_size等
#新增表INFORMATION_SCHEMA.INNODB_CACHED_INDEXES,显示每个索引在InnoDB缓存池中索引页数
#新增视图 INFORMATION_SCHEMA.INNODB_TABLESPACES_BRIEF, 为InnoDB表空间提供相关元数据信息
#默认创建2个UNDO表空间,不再使用系统表空间.
#支持ALTER TABLESPACE...RENAME TO 重命名通用表空间
#支持使用 innodb_directories 选项在服务器停止时将表空间文件移动到新的位置
#InnoDB 表空间加密特性支持重做日志和撤销日志
