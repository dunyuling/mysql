#/bin/bash

dbs=("aop" "aop_transaction" "cloudDB01"  "dubbo_one" "dubbo_two" "hibernate_annotation" "hibernate_cache" "hibernate_test" "hibernate_test2" "hibernate_test3" "jdbc" "mybatis_autoreplyrobots" "seckill" "spring_data" "spring_transaction" "webshop" "webshop2")
for db in ${dbs[@]}
do
    # mysql -uroot -pmysql  $db < $db.sql
done
