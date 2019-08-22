
set autocommit=off;

use cloudDB01
;
/* 
drop table if exists account;
create table account (
	id int primary key auto_increment,
	name varchar(20) not null,
	balance float(10)
);


insert into account(name,balance) values('lhg',1000);
insert into account(name,balance) values('mm', 1000 );
*/

/*
begin;
update account set balance = 500 where id = 1;
update account set balance = 1500 where id = 2;	
rollback;
*/

-- select @@tx_isolation;
-- select @@autocommit;
-- set session transaction isolation level read uncommitted;
-- set session transaction isolation level read committed;
-- set session transaction isolation level repeatable read;
-- set session transaction isolation level serializable;


-- 0:source   1:uncommitted(swap) 	2:committed  

-- =============================== 循环

## 查看存储过程
1. show procedure status where db=yourdb; 
2. select *  from mysql.proc where db = yourdb and `type` = 'PROCEDURE' \G

## 创建存储过程
truncate account;
drop procedure if exists myp0;
DELIMITER $
create procedure myp0(IN base_name varchar(20),out p_out int)
begin
	declare v int;
	declare startTime datetime;
	declare endTime datetime;
	set v = 1;
	select now() into startTime;
	repeat 	
	insert into account 
		values(null,concat(base_name,v),v);
	set v = v+1;
	until v > 10000
	end repeat;
	set p_out:=v; 
	select now() into endTime;		
	select startTime,endTime;
end	$
DELIMITER ;
set @count = 1;
call myp0('e',@count);

-- =============================== 有入参,有出参
truncate account;
drop procedure if exists myp1;
DELIMITER $
create procedure myp1(IN base_name varchar(20),inout count int)
begin
	declare startTime varchar(30);
	declare endTime varchar(30);
	select now() into startTime;
	repeat 	
	insert into account 
		values(null,concat(base_name,count),count);
		# values(null,base_name,count);
	set count = count+1;
	until count > 10000
	end repeat;	
	select now() into endTime;		
	select startTime,endTime;
end	$
DELIMITER ;
select 1 into @count;
call myp1('e',@count);

-- =============================== 多出参
drop procedure if exists myp2;
DELIMITER $
create procedure myp2(out c1 int ,out c2 int)
begin
	select 100,200 into c1,c2;
end	$
DELIMITER ;
call myp2(@c1,@c2);
select @c1 as c1,@c2 as c2;


-- =============================== 日期转换
drop procedure if exists myp3;
DELIMITER $
create procedure myp3(in myDate datetime, out strDate varchar(30))
begin
	select date_format(myDate, '%W-%m-%Y') into strDate;
end $
DELIMITER ;
call myp3(now(),@strDate);
select @strDate;


-- =============================== 函数
-- =============================== 示例  定义局部变量
drop function if exists f1;
DELIMITER $
create function f1() returns int
begin
	declare total int;
	select count(*) into total from account;
	return total;
end	$
DELIMITER ;
select f1();

-- =============================== 示例  定义用户变量
drop function if exists f2;
DELIMITER $
create function f2() returns int
begin
	set @total = 0;
	select count(*) into @total from account;
	return @total;
end	$
DELIMITER ;
select f2();

-- ====================== 分支结构
-- ====================== case 1
drop procedure if exists case1;
DELIMITER $
CREATE PROCEDURE case1()
  BEGIN
    DECLARE v INT DEFAULT 1;

    CASE v
      WHEN 2 THEN SELECT v;
      WHEN 3 THEN SELECT 0;
      ELSE
        BEGIN
        	select 100 as v;
        END;
    END CASE;
  END $
DELIMITER ;	
call case1();

-- ====================== case 2
drop procedure if exists case2;
DELIMITER $
CREATE PROCEDURE case2(in score int)
  BEGIN
    CASE 
      WHEN score>=90 and score<=100 THEN SELECT 'A';
      WHEN score>=80 and score < 90 THEN SELECT 'B';
      WHEN score>=70 and score < 80 THEN SELECT 'C';
      WHEN score>=60 and score < 70 THEN SELECT 'D';
      ELSE
        BEGIN
        	SELECT 'E';
        END;
    END CASE;
  END $
DELIMITER ;	
call case2(100);

-- ====================== if 1
drop procedure if exists if1;
DELIMITER $
CREATE PROCEDURE if1(in score int)
  BEGIN
      if score>=90 and score<=100 THEN SELECT 'A';
      elseif score>=80 and score < 90 THEN SELECT 'B';
      elseif score>=70 and score < 80 THEN SELECT 'C';
      elseif score>=60 and score < 70 THEN SELECT 'D';
      else SELECT 'E';
      END if;
  END $
DELIMITER ;	
call if1(100);



