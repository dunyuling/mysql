use join_test;

drop table if exists tbl_orderby;
create table tbl_orderby(
	id int primary key auto_increment,
	age int not null default 0,
	birth timestamp not null default current_timestamp
);

insert into tbl_orderby(age,birth) values(22,now());
insert into tbl_orderby(age,birth) values(23,now());
insert into tbl_orderby(age,birth) values(24,now());	

create index idx_tbl_orderby_ageBirth on tbl_orderby(age,birth);