use join_test;

drop table if exists article;
create table if not exists article(
    id int unsigned not null primary key auto_increment,
    author_id int unsigned not null,
    category_id int unsigned not null,
    views int unsigned not null,
    comments int unsigned not null,
    title varbinary(255) not null,
    content text not null
);

insert into article(author_id,category_id,views,comments,title,content)
	values(1,1,1,1,'1','1'),
	(2,2,2,2,'2','2'),
	(1,1,3,3,'3','3'),
	(1,1,4,4,'4','4');

select * from article;

#查询category_id为1 且comments 大于1的情况下,views 最多的 author_id
explain select id,author_id from article where category_id = 1 and comments > 1 order by views desc limit 1;

#结论: 很显然,type 是ALL ,即最坏的情况.Extra里还出现了Using file sort,也是最坏的情况. 必须优化

#开始优化
#1.1 新建索引
#alter table article add index idx_article_ccv(category_id,comments,views);
create index idx_article_ccv on article(category_id,comments,views);
#1.2 再次explain	
explain select id,author_id from article where category_id = 1 and comments > 1 order by views desc limit 1;
#结论 type 是 range ,有改善.Extra里还有Using file sort,是最坏的情况. 必须优化
#原因,comments 是个范围,导致 views 索引失效
#1.3 删除索引
drop index idx_article_ccv on article;


#2.1 再建索引
create index idx_article_cv on article(category_id,views);
#2.2 再次explain	
explain select id,author_id from article where category_id = 1 and comments > 1 order by views desc limit 1;
#结论 type 是 range ,有改善.Extra为 Using index condition; Using where,可以接收.

/*
explain select id,comments from article
	where category_id = 1 
	group by id,comments
	having comments > 1
	order by comments desc
	limit 1;
*/
