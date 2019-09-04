#窗口函数基本概念
#MySQL 8.0 开始支持窗口函数(Window Function),也称分析函数
#窗口函数与分组聚合函数类似,但是每一行数据都生产一个结果
#聚合窗口函数 SUM/AVG/MAX/MIN/COUNT
drop table if exists sales;
create table sales(
    year year,
    country varchar(20),
    product varchar(20),
    profit int
);
insert into sales (year, country, product, profit)
values (2000,'Finland','Computer',1500),
       (2001,'USA','Computer',1200),
       (2001,'Finland','Phone',10),
       (2000,'India','Calculator',75),
       (2001,'USA','TV',150),
       (2000,'India','Computer',1200),
       (2000,'USA','Calculator',5),
       (2000,'USA','Computer',1500),
       (2000,'Finland','Phone',100),
       (2001,'USA','Calculator',50),
       (2001,'USA','Computer',1500),
       (2001,'India','Calculator',75),
       (2001,'USA','TV',100);
#计算国家利润
#<1>聚合函数
select country,sum(profit) as country_profit 
	from sales 
	group by country
	order by country;
#+---------+----------------+
#| country | country_profit |
#+---------+----------------+
#| Finland |           1610 |
#| India   |           1350 |
#| USA     |           4505 |
#+---------+----------------+
#<2>窗口函数
select year,country,product,profit ,
	sum(profit) over(partition by country) as country_profit
	from sales
	order by country,year,product,profit;
#+------+---------+------------+--------+----------------+
#| year | country | product    | profit | country_profit |
#+------+---------+------------+--------+----------------+
#| 2000 | Finland | Computer   |   1500 |           1610 |
#| 2000 | Finland | Phone      |    100 |           1610 |
#| 2001 | Finland | Phone      |     10 |           1610 |
#| 2000 | India   | Calculator |     75 |           1350 |
#| 2000 | India   | Computer   |   1200 |           1350 |
#| 2001 | India   | Calculator |     75 |           1350 |
#| 2000 | USA     | Calculator |      5 |           4505 |
#| 2000 | USA     | Computer   |   1500 |           4505 |
#| 2001 | USA     | Calculator |     50 |           4505 |
#| 2001 | USA     | Computer   |   1200 |           4505 |
#| 2001 | USA     | Computer   |   1500 |           4505 |
#| 2001 | USA     | TV         |    100 |           4505 |
#| 2001 | USA     | TV         |    150 |           4505 |
#+------+---------+------------+--------+----------------+


#专用窗口函数
#数据排名
ROW_NUMBER()/RANK()/DENSE_RANK()/PERCENT_RANK()
#分组窗口第一名/最后一名/前几名/后几名
FIRST_VALUE()/LAST_VALUE()/LEAD()/LAG()
#累计分布/排名第几/百分位
CUME_DIST()/NTH_VALUE()/NTILE()

drop table if exists numbers;
create table numbers(val int);
insert into numbers(val) values(1),(1),(2),(3),(3),(3),(3),(4),(4),(5);	
#分析
select val,row_number() over (order by val) as 'row_number' 
	from numbers;
#+------+------------+
#| val  | row_number |
#+------+------------+
#|    1 |          1 |
#|    1 |          2 |
#|    2 |          3 |
#|    3 |          4 |
#|    3 |          5 |
#|    3 |          6 |
#|    3 |          7 |
#|    4 |          8 |
#|    4 |          9 |
#|    5 |         10 |
#+------+------------+
select val,RANK() over (order by val) as 'row_number' 
	from numbers;
#+------+------------+
#| val  | row_number |
#+------+------------+
#|    1 |          1 |
#|    1 |          1 |
#|    2 |          3 |
#|    3 |          4 |
#|    3 |          4 |
#|    3 |          4 |
#|    3 |          4 |
#|    4 |          8 |
#|    4 |          8 |
#|    5 |         10 |
#+------+------------+	

select val,
	FIRST_VALUE(val) over w as 'first_value', 
	LAST_VALUE(val) over w as 'last_value',
	LEAD(val,1) over w as 'lead',
	LAG(val,1) over w as 'lag' 
	from numbers
	WINDOW w AS (ORDER BY val);
#+------+-------------+------------+------+------+
#| val  | first_value | last_value | lead | lag  |
#+------+-------------+------------+------+------+
#|    1 |           1 |          1 |    1 | NULL |
#|    1 |           1 |          1 |    2 |    1 |
#|    2 |           1 |          2 |    3 |    1 |
#|    3 |           1 |          3 |    3 |    2 |
#|    3 |           1 |          3 |    3 |    3 |
#|    3 |           1 |          3 |    3 |    3 |
#|    3 |           1 |          3 |    4 |    3 |
#|    4 |           1 |          4 |    4 |    3 |
#|    4 |           1 |          4 |    5 |    4 |
#|    5 |           1 |          5 | NULL |    4 |
#+------+-------------+------------+------+------+


#窗口定义
Window Function(expr)
	over(
    	[window_name] 
    	[partition_clause]:
    		PARTITION BY expr [, expr] ...
    	[order_clause]:
    		ORDER BY expr [ASC|DESC] [, expr [ASC|DESC]] ...
    	[frame_clause]
		)