mysqlslap -hlocalhost -uroot -pmysql --concurrency=4000 --iterations=1 --auto-generate-sql --auto-generate-sql-load-type=mixed --auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=5000 
