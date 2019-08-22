drop database if exists join_test;
create database join_test;
use join_test;

#
drop table if exists `tbl_dept`;
create table `tbl_dept` (
	`id` int not null auto_increment,
	`deptName` varchar(30) default null,
	`locAdd` varchar(40) default null, #位置 locationAddress
	primary key(`id`)
) ENGINE=INNODB auto_increment=1 default charset=utf8;

#
drop table if exists `tbl_emp`;
create table `tbl_emp` (
	`id` int not null auto_increment,
	`name` varchar(20) default null,
	`deptId` int default null,
	primary key(`id`)
	# constraint `fk_dept_id` foreign key references `tbl_dept`(`id`)
)ENGINE=INNODB auto_increment=1 default charset=utf8;	

#
insert into tbl_dept(deptName,locAdd) values('RD',11);
insert into tbl_dept(deptName,locAdd) values('HR',12);
insert into tbl_dept(deptName,locAdd) values('MK',13);
insert into tbl_dept(deptName,locAdd) values('MIS',14);
insert into tbl_dept(deptName,locAdd) values('FD',15);

#
insert into tbl_emp(name,deptId) values('z3',1); 
insert into tbl_emp(name,deptId) values('z4',1);
insert into tbl_emp(name,deptId) values('z5',1);

insert into tbl_emp(name,deptId) values('w5',2);
insert into tbl_emp(name,deptId) values('w6',2);

insert into tbl_emp(name,deptId) values('s7',3);

insert into tbl_emp(name,deptId) values('s8',4);

insert into tbl_emp(name,deptId) values('s9',51);	


#1.
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
	from tbl_dept d inner join tbl_emp e on  d.id=e.deptId;

#2
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
  from tbl_dept d left join tbl_emp e on  d.id=e.deptId;

#3
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
 from tbl_dept d right join tbl_emp e on  d.id=e.deptId; 

#4
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
  from tbl_dept d left join tbl_emp e on  d.id=e.deptId
  where e.id is null;

#5  
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
 from tbl_dept d right outer join tbl_emp e on  d.id=e.deptId
 where d.id is null;

 #6
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
  from tbl_dept d left join tbl_emp e on  d.id=e.deptId
  where e.id is null
union
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
 from tbl_dept d right outer join tbl_emp e on  d.id=e.deptId
 where d.id is null;  

#7
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
  from tbl_dept d left join tbl_emp e on  d.id=e.deptId
union all
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
 from tbl_dept d right outer join tbl_emp e on  d.id=e.deptId;



##
explain select * from tbl_dept d left join tbl_emp e on  d.id=e.deptId
union
select * from tbl_dept d right outer join tbl_emp e on  d.id=e.deptId;

 explain select s.* from (
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
  from tbl_dept d left join tbl_emp e on  d.id=e.deptId
union
select e.id as 员工id , e.name as 员工名称, e.deptId as 员工部门id, d.id as 部门id, d.deptName as 部门名称 ,d.locAdd as 部门位置
 from tbl_dept d right outer join tbl_emp e on  d.id=e.deptId
 ) as s;