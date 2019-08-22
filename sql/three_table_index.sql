use join_test;

drop table if exists class;
create table if not exists class(
    id int unsigned not null primary key auto_increment,
    card int unsigned not null
);

drop table if exists book;
create table if not exists book(
    bookid int unsigned not null primary key auto_increment,
    card int unsigned not null
);

drop table if exists phone;
create table if not exists phone(
    phoneid int unsigned not null primary key auto_increment,
    card int unsigned not null
);

##创建填充 class 表的存储过程
drop procedure if exists insert_class;
truncate table class;
DELIMITER $
create procedure insert_class()
begin
	declare count int default 1;
	declare startTime varchar(30);
	declare endTime varchar(30);
	select now() into startTime;
	repeat 	
	insert into class(card) values(floor(1+(rand()*20)));
	set count = count+1;
	until count > 20
	end repeat;	
	select now() into endTime;		
	select startTime,endTime;
end	$
DELIMITER ;
call insert_class();

##创建填充 book 表的存储过程
drop procedure if exists insert_book;
truncate table book;
DELIMITER $
create procedure insert_book()
begin
	declare count int default 1;
	declare startTime varchar(30);
	declare endTime varchar(30);
	select now() into startTime;
	repeat 	
	insert into book(card) values(floor(1+(rand()*20)));
	set count = count+1;
	until count > 20
	end repeat;	
	select now() into endTime;		
	select startTime,endTime;
end	$
DELIMITER ;
call insert_book();

##创建填充 phone 表的存储过程
drop procedure if exists insert_phone;
truncate table phone;
DELIMITER $
create procedure insert_phone()
begin
	declare count int default 1;
	declare startTime varchar(30);
	declare endTime varchar(30);
	select now() into startTime;
	repeat 	
	insert into phone(card) values(floor(1+(rand()*20)));
	set count = count+1;
	until count > 20
	end repeat;	
	select now() into endTime;		
	select startTime,endTime;
end	$
DELIMITER ;
call insert_phone();


#使用explain 分析
explain select * from class 
	left join book on class.card = book.card
	left join phone on book.card = phone.card;
#结论:
#1. table:phone,type:ALL,key:NULL,extra:Using where; Using join buffer (Block Nested Loop)
#2. table:book,type:ALL,key:NULL,extra:Using where; Using join buffer (Block Nested Loop)


# 添加索引
create index idx_book_card on book(card);
create index idx_phone_card on phone(card);
#结论:
#1. table:phone, type:ref, key:idx_phone_card, extra:Using index
#2. table:book, type:ref, key:idx_book_card, extra:Using index
#结果满意
#索引应该加在从表上

#优化
#尽量减少Join语句中的Nested Loop总次数:"永远用小结果集驱动大结果集"
#优先优化Nested Loop的内层循环
#保证Join语句中被驱动表上Join字段已经加索引
#当无法保证被驱动表的Join字段被索引且内存资源充足的前提下,不要太吝惜JoinBuffer的设置.

