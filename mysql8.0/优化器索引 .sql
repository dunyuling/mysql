#1.隐藏索引
#隐藏索引不会被优化器使用,但仍然需要维护
#应用场景:软删除,灰度发布
#创建隐藏索引
create database if not exists test;
create table t1(i int,j int);
create index idx_i  on t1(i);
create index idx_j  on t1(j) invisible;
show index from t1; #关注visible属性
#测试效果
#普通索引可以用到
explain select * from t1 where i = 1;
#+----+-------------+-------+------------+------+---------------+-------+---------+-------+------+----------+-------+
#| id | select_type | table | partitions | type | possible_keys | key   | key_len | ref   | rows | filtered | Extra |
#+----+-------------+-------+------------+------+---------------+-------+---------+-------+------+----------+-------+
#|  1 | SIMPLE      | t1    | NULL       | ref  | idx_i         | idx_i | 5       | const |    1 |   100.00 | NULL  |
#+----+-------------+-------+------------+------+---------------+-------+---------+-------+------+----------+-------+
#隐藏索引不能用到
explain select * from t1 where j = 1;
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
#| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
#|  1 | SIMPLE      | t1    | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    1 |   100.00 | Using where |
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
#开启隐藏索引
select @@optimizer_switch\G #查看优化器
set session optimizer_switch='on,use_invisible_indexes=on';#开启优化器对隐藏索引的使用
explain select * from t1 where j = 1;
#+----+-------------+-------+------------+------+---------------+-------+---------+-------+------+----------+-------+
#| id | select_type | table | partitions | type | possible_keys | key   | key_len | ref   | rows | filtered | Extra |
#+----+-------------+-------+------------+------+---------------+-------+---------+-------+------+----------+-------+
#|  1 | SIMPLE      | t1    | NULL       | ref  | idx_j         | idx_j | 5       | const |    1 |   100.00 | NULL  |
#+----+-------------+-------+------------+------+---------------+-------+---------+-------+------+----------+-------+
#改变索引可见性
alter table t1 alter index idx_j visible|invisible; 
#主键索引必须可见
create table t2(id int);
alter table t2 add primary key pk_id(id) invisible;
#ERROR 3522 (HY000): A primary key index cannot be invisible

#2.降序索引 
#MySQL 8.0 开始真正支持降序索引(descending index)
#只有InnoDB存储引擎支持降序索引,只支持BTREE降序索引
#MySQL 8.0不再对GROUP BY操作进行隐式排序
#测试
create table t3(c1 int ,c2 int, index idx1(c1 asc ,c2 desc));
show create table t3;
insert into t3(c1,c2) values(1,100),(2,200),(3,300),(4,130);
explain select * from t3 order by c1, c2 desc;
#+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+-------------+
#| id | select_type | table | partitions | type  | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
#+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+-------------+
#|  1 | SIMPLE      | t3    | NULL       | index | NULL          | idx1 | 10      | NULL |    1 |   100.00 | Using index |
#+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+-------------+
explain select * from t3 order by c1 desc, c2; 
#Extra:Backward index scan;
#+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+----------------------------------+
#| id | select_type | table | partitions | type  | possible_keys | key  | key_len | ref  | rows | filtered | Extra                            |
#+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+----------------------------------+
#|  1 | SIMPLE      | t3    | NULL       | index | NULL          | idx1 | 10      | NULL |    1 |   100.00 | Backward index scan; Using index |
#+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+----------------------------------+
#group by 不再支持默认排序
select count(*) ,c2 from t3 group by c2;

#3.函数索引
#MySQL 8.0.13开始支持在函数中使用函数(表达式)的值
#支持降序索引,支持JSON数据的索引
#函数索引基于虚拟列功能实现
create table t4(c1 varchar(10),c2 varchar(10));
create index idx1 on t4(c1);
create index idx_func on t4((UPPER(c2)));
show index  from t4;	
#测试
#1)
#1.1)
explain select * from t4 where c1 = 'ABC';
#+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
#| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref   | rows | filtered | Extra |
#+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
#|  1 | SIMPLE      | t4    | NULL       | ref  | idx1          | idx1 | 43      | const |    1 |   100.00 | NULL  |
#+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
explain select * from t4 where c2 = 'ABC';
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
#| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
#|  1 | SIMPLE      | t4    | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    1 |   100.00 | Using where |
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
#1.2)
explain select * from t4 where upper(c1) = 'ABC';
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
#| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
#|  1 | SIMPLE      | t4    | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    1 |   100.00 | Using where |
#+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
explain select * from t4 where upper(c2) = 'ABC';
#+----+-------------+-------+------------+------+---------------+----------+---------+-------+------+----------+-------+
#| id | select_type | table | partitions | type | possible_keys | key      | key_len | ref   | rows | filtered | Extra |
#+----+-------------+-------+------------+------+---------------+----------+---------+-------+------+----------+-------+
#|  1 | SIMPLE      | t4    | NULL       | ref  | idx_func      | idx_func | 43      | const |    1 |   100.00 | NULL  |
#+----+-------------+-------+------------+------+---------------+----------+---------+-------+------+----------+-------+
#json索引
create table emp(data json,index((CAST(data->>'$.name' as char(30)))));
explain select * from emp where CAST(data->>'$.name' as char(30))='abc';
#+----+-------------+-------+------------+------+------------------+------------------+---------+-------+------+----------+-------+
#| id | select_type | table | partitions | type | possible_keys    | key              | key_len | ref   | rows | filtered | Extra |
#+----+-------------+-------+------------+------+------------------+------------------+---------+-------+------+----------+-------+
#|  1 | SIMPLE      | emp   | NULL       | ref  | functional_index | functional_index | 33      | const |    1 |   100.00 | NULL  |
#+----+-------------+-------+------------+------+------------------+------------------+---------+-------+------+----------+-------+
#虚拟计算列
alter table t4 add column c3 varchar(10) generated always as (upper(c1));
insert into t4(c1,c2) values('abc','abc');
select * from t4;
#+------+------+------+
#| c1   | c2   | c3   |
#+------+------+------+
#| abc  | abc  | ABC  |
#+------+------+------+
create index idx3 on t4(c3);
explain select * from t4 where upper(c1) = 'ABC';
#+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
#| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref   | rows | filtered | Extra |
#+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
#|  1 | SIMPLE      | t4    | NULL       | ref  | idx3          | idx3 | 43      | const |    1 |   100.00 | NULL  |
#+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+


