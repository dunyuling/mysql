#1.用户创建和授权
#mysql 5.7
grant all priviledges on *.* to 'test'@'%' identified by 'test1234';
select user,host from mysql.user;
#mysql 8.0	
create user 'test'@'%' identified by 'test1234';
grant all on *.* to 'test'@'%';	
select user,host from mysql.user;

#2.认证插件更新
##验证
#方式1
show variables like 'default_authentication_plugin';
#方式2
select user,host ,plugin from mysql.user;
#结果
#mysql 5.7
mysql_native_password
#mysql 8.0	
caching_sha2_password
#mysql8.0 修改插件认证方式
alter user 'test'@'%' IDENTIFIED WITH mysql_native_password BY 'test1234';

#3.密码管理策略
#mysql8.0开始允许限制重复使用以前的密码
show variables like 'password_%';
#+--------------------------+-------+
#| Variable_name            | Value |
#+--------------------------+-------+
#| password_history         | 0     |  记录用户最近多少次的密码
#| password_require_current | OFF   |  修改密码时需要提供当前用户密码
#| password_reuse_interval  | 0     |  记录最近多少天的用户密码
#+--------------------------+-------+
#持久化改变
#全局设置
#对应文件 /var/lib/mysql/mysqld-auto.cnf
set persist password_history=3; 
#对于当前用户的设置
alter user 'test'@'%' password history 2;
select user,host,password_reuse_history from mysql.user; #查看某用户的密码重用次数
alter user 'test'@'%' IDENTIFIED BY 'test5678';
select * from mysql.password_history; #某个用户已经使用过的密码

#4.角色管理
#创建角色
create role 'write_role';
select user,host,authentication_string from mysql.user;
#赋予一组权限
grant insert ,update ,delete on test.test to 'write_role'; #把test数据库的test表的插入,删除,修改权限赋予write_role角色
grant select on test.test to 'write_role'; #把test数据库的test表的查询权限赋予write_role角色
#把角色权限赋予用户
create user 'user1' identified by '1234'; #创建用户
grant 'write_role' to 'user1';	 #把角色赋予用户
show grants for 'user1'; #显示用户的权限
show grants for 'user1' using 'write_role'; #显示用户通过'write_role'角色获取的权限	
#退出使用user1登录
select current_role(); #查看当前用户角色
set role 'write_role'; #设置当前用户使用的角色
#退出使用root登录
set default role 'write_role' to 'user1'; #为用户设置默认角色
set default role all to 'user1'; #开启用户所有角色
#查看角色相关信息
select * from mysql.default_roles;
select * from mysql.role_edges;
#撤销角色权限
revoke insert ,update ,delete on test.test from 'write_role';
