use join_test;

drop table if exists test03;
create table test03(
	id int primary key auto_increment,
	c1 char(10),
	c2 char(10),
	c3 char(10),
	c4 char(10),
	c5 char(10)
);	

insert into test03(c1,c2,c3,c4,c5) values('a1','a2','a3','a4','a5');
insert into test03(c1,c2,c3,c4,c5) values('b1','b2','b3','b4','b5');
insert into test03(c1,c2,c3,c4,c5) values('c1','c2','c3','c4','c5');
insert into test03(c1,c2,c3,c4,c5) values('d1','d2','d3','d4','d5');
insert into test03(c1,c2,c3,c4,c5) values('e1','e2','e3','e4','e5');	

select * from test03;	

create index idx_test03_c1234 on test03(c1,c2,c3,c4);
explain select * from test03 where c1='a1';
explain select * from test03 where c1='a1' and c2='a2';	
explain select * from test03 where c1='a1' and c2='a2' and c3='a3';	
explain select * from test03 where c1='a1' and c2='a2' and c3='a3' and c4='a4';