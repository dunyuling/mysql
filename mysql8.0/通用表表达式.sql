#1.非递归CTE
#MySQL 8.0 开始支持通用表表达式(CTE),即WITH子句
#派生表:
select * from (select 1) as dt;
#通用表表达式:
with cte as (select 1) 
	select * from cte;

with cte1(id) as (select 1),
	cte2(id) as (select id + 1 from cte1)
	select cte1.id,cte2.id from cte1 join cte2;	


#2.递归CTE
#递归CTE在查询中引用自己的定义,使用RECURSIVE表示.
#demo1
with recursive cte(n) as
(
    select 1
    union all
    select n+1 from cte where n < 5
)
select n from cte;
#demo2
create table emps(id int primary key , name varchar(20), manager_id int );
insert into emps(id,name,manager_id) 
	values(29,'Pedro',198),(72,'Pierre',29),(123,'Adil',692),(198,'John',333),
		(333,'Yasmina',null),(692,'Terak',333),(4610,'Sarah',29);

with recursive emps_path(id,name,path) as
(
	select id,name,cast(id as char(100))
	from emps
	where manager_id is null
	union all
	select e.id,e.name,concat(ep.path,',',e.id) 
	from emps e join emps_path ep 
	on e.manager_id = ep.id
)
select * from emps_path;		
#广度优先遍历
#+------+---------+-----------------+
#| id   | name    | path            |
#+------+---------+-----------------+
#|  333 | Yasmina | 333             |
#|  198 | John    | 333,198         |
#|  692 | Terak   | 333,692         |
#|   29 | Pedro   | 333,198,29      |
#|  123 | Adil    | 333,692,123     |
#|   72 | Pierre  | 333,198,29,72   |
#| 4610 | Sarah   | 333,198,29,4610 |
#+------+---------+-----------------+

#3.递归限制
#递归表达式的查询中需要包含一个终止递归的条件
#最大递归深度: cte_max_recursion_depth
select @@cte_max_recursion_depth;
with recursive cte(n) as
(
    select 1
    union all
    select n+1 from cte
)
select * from cte;
#ERROR 3636 (HY000): Recursive query aborted after 1001 iterations. Try increasing @@cte_max_recursion_depth to a larger value
#最大执行时间: max_execution_time
select @@max_execution_time;
set session cte_max_recursion_depth=99999999999;
set @@max_execution_time=1000;
with recursive cte(n) as
(
    select 1
    union all
    select n+1 from cte
)
select * from cte;
#ERROR 3024 (HY000): Query execution was interrupted, maximum statement execution time exceeded

#4.小结
#通用表表达式与派生表类似,就像语句级别的临时表或视图
#CTE可以在查询中多次引用,可以引用其他CTE,可以递归
#CTE支持CRUD等语句
with recursive cte(n) as
(
    select 1
    union all
    select n+1 from cte where n < 5
)
select n from cte;

#斐波那契数列(0,1,1,2,3,5,8...)
#本程序关键
#1>下一项要变化(前两项之和)
#2>保存下一项(pre+next)->next
#3>下一项的位置(count)
#level1
with recursive cte(pre,next,count) as
(
    select 0,1,2
    union all
    select pre+next,next+(pre+next),count+1 from cte where count<6
)
select pre,next from cte;
#level2 finish
with recursive cte(pre,next,count) as
(
    select 0,1,1
    union all
    select next,(pre+next),count+1 from cte where count<10
)
select * from cte;