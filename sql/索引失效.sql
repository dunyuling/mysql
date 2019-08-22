use join_test;

drop table if exists staffs;
create table staffs(
	id int primary key auto_increment,
	name varchar(24) not null default '' comment '姓名',
	age int not null default 0 comment '年龄',
	pos varchar(20) not null default '' comment '职位',
	add_time timestamp not null default current_timestamp comment '入职时间'
) charset utf8 comment '员工记录表';

insert into staffs(name,age,pos,add_time) values('z3',22,'manager',now());
insert into staffs(name,age,pos,add_time) values('july',23,'dev',now());
insert into staffs(name,age,pos,add_time) values('2000',23,'dev',now());	

select * from staffs;

alter table staffs add index idx_staffs_nameAgePos(name,age,pos);

#注意: mysql不同版本对于索引的处理会有不同(当前版本:5.7.27)
#1.全值匹配我最爱
explain select * from staffs where name = 'july';
explain select * from staffs where name = 'july' and age = 23;
explain select * from staffs where name = 'july' and age = 23 and pos='dev';

#2.最佳左前缀法则
explain select * from staffs where age = 23;
explain select * from staffs where name = 'july' and pos='dev';
#口诀:带头大哥不能死,中间兄弟不能断

#3.不在索引列上做任何操作(计算,函数,(手动or自动)类型转换),会导致索引失效转向全表扫描
explain select * from staffs where left(name,5) = 'July';
#结果 注意:仍然使用了索引
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+-----------------------+
#| id | select_type | table  | partitions | type  | possible_keys         | key                   | key_len | ref  | rows | filtered | Extra                 |
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+-----------------------+
#|  1 | SIMPLE      | staffs | NULL       | range | idx_staffs_nameAgePos | idx_staffs_nameAgePos | 78      | NULL |    1 |    33.33 | Using index condition |
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+-----------------------+
#口诀:索引列上不计算

#4.存储引擎不能使用索引范围中条件右边的列
explain select * from staffs where name = 'july' and age > 25 and pos='dev';
explain select * from staffs where name = 'july' and pos='dev' and age > 25;
#口诀:范围之后全失效

#5.尽量使用覆盖索引(只访问索引的查询(索引列和查询列一致)),减少select *
explain select name,age ,pos from staffs where name ='july' and pos='dev' and age = 25; #注意pos,age顺序.实际并无影响
explain select name,age,pos from staffs where name ='july' and age = 25 and pos = 'dev';
explain select name,age,pos from staffs where name ='july'  and age = 25 ;
explain select name from staffs where name ='july'  and age = 25 ;
#口诀:

#6.mysql在使用不等于(!= 或者 <>)的时候无法使用索引会导致全表扫描
explain select name from staffs where name != 'july';#注意:实测结果为range
#结果:
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+--------------------------+
#| id | select_type | table  | partitions | type  | possible_keys         | key                   | key_len | ref  | rows | filtered | Extra                    |
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+--------------------------+
#|  1 | SIMPLE      | staffs | NULL       | range | idx_staffs_nameAgePos | idx_staffs_nameAgePos | 74      | NULL |    2 |   100.00 | Using where; Using index |
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+--------------------------+


#7.is null,is not null无法使用索引
explain select name from staffs where name is null;
#结果
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+------------------+
#| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra            |
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+------------------+
#|  1 | SIMPLE      | NULL  | NULL       | NULL | NULL          | NULL | NULL    | NULL | NULL |     NULL | Impossible WHERE |
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+------------------+
explain select name from staffs where name is not null;
#结果 注意:这里可以使用索引
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+--------------------------+
#| id | select_type | table  | partitions | type  | possible_keys         | key                   | key_len | ref  | rows | filtered | Extra                    |
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+--------------------------+
#|  1 | SIMPLE      | staffs | NULL       | index | idx_staffs_nameAgePos | idx_staffs_nameAgePos | 140     | NULL |    3 |    66.67 | Using where; Using index |
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+--------------------------+

#8.like以通配符开头('%abc...')mysql索引失效会变成全表扫描的操作
explain select name from staffs where name like '%july%';
explain select name from staffs where name like '%july';
#结果 注意:虽然使用index索引,应该还是全表扫描(rows=3,表内共有三条记录),还是版本在影响
#+----+-------------+--------+------------+-------+---------------+-----------------------+---------+------+------+----------+--------------------------+
#| id | select_type | table  | partitions | type  | possible_keys | key                   | key_len | ref  | rows | filtered | Extra                    |
#+----+-------------+--------+------------+-------+---------------+-----------------------+---------+------+------+----------+--------------------------+
#|  1 | SIMPLE      | staffs | NULL       | index | NULL          | idx_staffs_nameAgePos | 140     | NULL |    3 |    33.33 | Using where; Using index |
#+----+-------------+--------+------------+-------+---------------+-----------------------+---------+------+------+----------+--------------------------+
explain select name from staffs where name like 'july%';
#结果 注意:type, possible_keys 和 key_len,row 与上面不同
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+--------------------------+
#| id | select_type | table  | partitions | type  | possible_keys         | key                   | key_len | ref  | rows | filtered | Extra                    |
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+--------------------------+
#|  1 | SIMPLE      | staffs | NULL       | range | idx_staffs_nameAgePos | idx_staffs_nameAgePos | 74      | NULL |    1 |   100.00 | Using where; Using index |
#+----+-------------+--------+------------+-------+-----------------------+-----------------------+---------+------+------+----------+--------------------------+
explain select id ,name ,add_time from staffs where name like '%july%';
explain select * from staffs where name like '%july%';
#结果 注意:add_time列没有建立索引
#+----+-------------+--------+------------+------+---------------+------+---------+------+------+----------+-------------+
#| id | select_type | table  | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
#+----+-------------+--------+------------+------+---------------+------+---------+------+------+----------+-------------+
#|  1 | SIMPLE      | staffs | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    3 |    33.33 | Using where |
#+----+-------------+--------+------------+------+---------------+------+---------+------+------+----------+-------------+
#口诀:%like记右边,范围之后全失效
#两边都有%,则使用覆盖索引


#9.字符串不加单引号索引失效
explain select * from staffs where name = '2000';
#结果
#+----+-------------+--------+------------+------+-----------------------+-----------------------+---------+-------+------+----------+-------+
#| id | select_type | table  | partitions | type | possible_keys         | key                   | key_len | ref   | rows | filtered | Extra |
#+----+-------------+--------+------------+------+-----------------------+-----------------------+---------+-------+------+----------+-------+
#|  1 | SIMPLE      | staffs | NULL       | ref  | idx_staffs_nameAgePos | idx_staffs_nameAgePos | 74      | const |    1 |   100.00 | NULL  |
#+----+-------------+--------+------------+------+-----------------------+-----------------------+---------+-------+------+----------+-------+
explain select * from staffs where name = 2000;
#结果
#+----+-------------+--------+------------+------+-----------------------+------+---------+------+------+----------+-------------+
#| id | select_type | table  | partitions | type | possible_keys         | key  | key_len | ref  | rows | filtered | Extra       |
#+----+-------------+--------+------------+------+-----------------------+------+---------+------+------+----------+-------------+
#|  1 | SIMPLE      | staffs | NULL       | ALL  | idx_staffs_nameAgePos | NULL | NULL    | NULL |    3 |    33.33 | Using where |
#+----+-------------+--------+------------+------+-----------------------+------+---------+------+------+----------+-------------+
#口诀:字符串里有引号

#10.少用or,用其连接会导致索引失效
explain select * from staffs where name = 'z3' or name='lsi';
#结果
#+----+-------------+--------+------------+------+-----------------------+------+---------+------+------+----------+-------------+
#| id | select_type | table  | partitions | type | possible_keys         | key  | key_len | ref  | rows | filtered | Extra       |
#+----+-------------+--------+------------+------+-----------------------+------+---------+------+------+----------+-------------+
#|  1 | SIMPLE      | staffs | NULL       | ALL  | idx_staffs_nameAgePos | NULL | NULL    | NULL |    3 |    66.67 | Using where |
#+----+-------------+--------+------------+------+-----------------------+------+---------+------+------+----------+-------------+


#索引优化口诀
#全值匹配我最爱，最左前缀要遵守；
#带头大哥不能死，中间兄弟不能断；
#索引列上少计算，范围之后全失效；
#Like百分写最右，覆盖索引不写星；
#不等空值还有or，索引失效要少用；
#VAR引号不可丢，SQL高级也不难！