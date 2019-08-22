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

#下面开始explain分析
explain select * from class left join book on book.card = class.card ;
#结论: type 为 ALL,extra 为 Using where; Using join buffer (Block Nested Loop);需要优化


#添加索引优化
alter table book add index idx_card(card);
#结论: type 为 ref, extra 为 using index;结果满意
#由左连接特性决定.left join 条件用于确定如何从右边搜索行,左边全有
#所以右边是关键点,一定要建立索引
