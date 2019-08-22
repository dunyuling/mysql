drop database if exists lock_test;
create database lock_test;
use lock_test;

# 表锁
drop table if exists table_lock;
create table table_lock(
	id int not null primary key auto_increment,
	name varchar(20)
) engine myisam;

insert into table_lock(name) values('a');
insert into table_lock(name) values('b');
insert into table_lock(name) values('c');
insert into table_lock(name) values('d');
insert into table_lock(name) values('e');

select * from table_lock;	

#手动增加表锁
lock table table_name read(write) ,table_name2 read(write)...

#释放锁
unlock tables;

#查看表是否被锁
show open tables;

#查看锁表情况
show status like 'table%';



#=======================
#行锁
drop table if exists row_lock;
create table row_lock(
	a int,
	b varchar(20)
) engine innodb;

insert into row_lock values(1,'b2');
insert into row_lock values(3,'3');
insert into row_lock values(4,'4000');
insert into row_lock values(5,'5000');
insert into row_lock values(6,'6000');
insert into row_lock values(7,'7000');
insert into row_lock values(8,'8000');
insert into row_lock values(9,'9000');	
insert into row_lock values(1,'b1');

select * from row_lock;	

#基于索引的锁,没有索引或索引失效行锁会变成表锁
#update row_lock set a = 42 where b = 4004; 这条sql会导致索引失效
create index idx_row_lock_a on row_lock(a);	
create index idx_row_lock_b on row_lock(b);	

#关闭自动提交
set autocommit = 0; 


#间隙锁
session1: update row_lock set b='1000' where a>1 and a<6; #尚未commit;
session2: insert into row_lock values(2,'2000'); #被阻塞

#分析
show status like 'innodb_row_lock%';