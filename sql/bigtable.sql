drop database if exists bigData;
create database bigData;
use bigData;

#
drop table if exists `tbl_dept`;
create table `tbl_dept` (
	`id` int not null auto_increment,
	`deptno` mediumint unsigned not null default 0,
	`dname` varchar(20) default null,
	`loc` varchar(13) default null, #位置 location
	primary key(`id`)
) ENGINE=INNODB auto_increment=1 default charset=utf8;

#
drop table if exists `tbl_emp`;
create table `tbl_emp` (
	`id` int unsigned not null auto_increment,
	`empno` mediumint unsigned not  null default 0,
	`ename` varchar(20) not null default '',
	`job` varchar(9) not null default '',
	`mgr` mediumint unsigned not null default 0, #manager
	hirdate date not null,
	sal decimal(7,2) not null, #salary
	comm decimal(7,2) not null, #红利
	deptno mediumint unsigned not null default 0,
	primary key(`id`)
	# constraint `fk_dept_id` foreign key references `tbl_dept`(`id`)
)ENGINE=INNODB auto_increment=1 default charset=utf8;	

#生成随机字符串
drop function if exists rand_string;
DELIMITER $
create function rand_string(n int) returns varchar(255)
begin
	declare chars_str varchar(100) default 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
	declare return_str varchar(255) default '';
	declare i int default 0;
	while i < n do
		set return_str = concat(return_str,substring(chars_str,floor(1+rand()*52),1));
		set i=i+1;
	end while;
	return return_str;
end $
DELIMITER ;

#生成随机部门编号
drop function if exists rand_num;
DELIMITER $
create function rand_num() returns int(5)
begin
	declare i int default 0;
	set i = floor(100+rand()*10);
	return i;
end $
DELIMITER ;


##创建填充 tbl_emp 表的存储过程
drop procedure if exists insert_emp;
truncate table tbl_emp;
DELIMITER $
create procedure insert_emp(in start int(10), in max_num int(10))
begin
	declare i int default 0;
	declare startTime varchar(30);
	declare endTime varchar(30);
	select now() into startTime;
	set autocommit=0;
	repeat 	
	set i=i+1;
	insert into tbl_emp(empno,ename,job,mgr,hirdate,sal,comm,deptno) 
		values((start+i),rand_string(6),'salesman',0001,curdate(),2000,400,rand_num());
	until i=max_num
	end repeat;
	commit;	
	select now() into endTime;		
	select startTime,endTime;
end	$
DELIMITER ;
call insert_emp(100001,10000000);



##创建填充 tbl_dept 表的存储过程
drop procedure if exists insert_dept;
truncate table tbl_dept;
DELIMITER $
create procedure insert_dept(in start int(10), in max_num int(10))
begin
	declare i int default 0;
	declare startTime varchar(30);
	declare endTime varchar(30);
	select now() into startTime;
	set autocommit=0;
	repeat 	
	set i=i+1;
	insert into tbl_dept(deptno,dname,loc) 
		values((start+i),rand_string(10),rand_string(8));
	until i=max_num
	end repeat;
	commit;	
	select now() into endTime;		
	select startTime,endTime;
end	$
DELIMITER ;
call insert_dept(100,10);