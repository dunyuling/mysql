#一.内联路径操作符
#MySQL8.0增加了JSON操作符 column->>path 等价于:
	JSON_UNQUOTE(column->path)
	JSON_UNQUOTE(JSON_EXTRACT(column,path))
#示例1.1:
with doc(data) as
(
	select json_object('id',3,'name','ll')
)	
select JSON_UNQUOTE(data->'$.name') from doc;
#示例1.2:
with doc(data) as
(
	select json_object('id',3,'name','ll')
)	
select JSON_UNQUOTE(JSON_EXTRACT(data,'$.name')) from doc;
#示例1.3:
with doc(data) as
(
	select json_object('id',3,'name','ll')
)	
select data->>'$.name' from doc;
#示例2.1:
select JSON_EXTRACT('["a","b","c","d","e"]','$[1]');
#示例2.2:
select JSON_EXTRACT('["a","b","c","d","e"]','$[1 to 3]');
#示例2.3:
select JSON_EXTRACT('["a","b","c","d","e"]','$[last-2 to last]');

#二.JSON聚合函数
#MySQL8.0(MySQL5.7.22)增加了两个聚合函数:
JSON_ARRAYAGG(),用于生成json数组
JSON_OBJECTAGG(),用于生成json对象
#具体示例通过 ? JSON_OBJECTAGG 和  ? JSON_ARRAYAGG 在mysql终端查看

#三.JSON实用函数
#MySQL8.0(MySQL5.7.22)增加了 JSON_PRETTY();
#MySQL8.0(MySQL5.7.22)增加了 JSON_STORAGE_SIZE();
#MySQL8.0增加了 JSON_STORAGE_FREE();
#在mysql终端通过 ? functionname 查看具体使用示例

#四.JSON合并函数
#MySQL8.0(MySQL5.7.22)增加了 JSON_MERGE_PATCH();
#MySQL8.0(MySQL5.7.22)增加了 JSON_MERGE_PRESERVE();
#MySQL8.0废弃了 JSON_MERGE().
#在mysql终端通过 ? functionname 查看具体使用示例

#五.JSON表函数
#MySQL8.0(MySQL5.7.22)增加了 JSON_TABLE(),将json数据转化为关系表
#可以将该函数返回结果作为一个普通表,使用sql进行查询
#在mysql终端通过 ? functionname 查看具体使用示例,若没有提示链接进行查看
