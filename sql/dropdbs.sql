USE test;

drop procedure if exists createdbs;
DELIMITER $
create PROCEDURE createdbs()
BEGIN
	DROP DATABASE aop;
	DROP DATABASE aop_transaction;
	DROP DATABASE dubbo_one;
	DROP DATABASE dubbo_two;
	DROP DATABASE hibernate_annotation;
	DROP DATABASE hibernate_cache;
	DROP DATABASE hibernate_test;
	DROP DATABASE hibernate_test2;
	DROP DATABASE hibernate_test3;
	DROP DATABASE jdbc;
	DROP DATABASE mybatis_autoreplyrobots;
	DROP DATABASE seckill;
	DROP DATABASE spring_data;
	DROP DATABASE spring_transaction;
	DROP DATABASE webshop;
	DROP DATABASE webshop2;
END $ 
DELIMITER ;
CALL createdbs();