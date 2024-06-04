#!/bin/bash

echo "Waiting for mysql initialization"

sleep 60

mysql --host mysql_slave -uroot -proot -e "stop slave;";
mysql --host mysql_slave -uroot -proot -e "reset slave all;";

# connect to mysql_master and execute the following commands


mysql --host mysql_master -uroot -proot -AN -e "GRANT REPLICATION SLAVE ON *.* TO 'repuser'@'%' IDENTIFIED BY 'reppassword';"
mysql --host mysql_master -uroot -proot -AN -e "FLUSH PRIVILEGES;"


Master_Position="$(mysql --host mysql_master -uroot -proot -e 'show master status \G'| grep Position | grep -o '[0-9]*')"
Master_File="$(mysql --host mysql_master -uroot -proot -e 'show master status \G'| grep File | sed -n -e 's/^.*: //p')"


#connect to mysql_slave db and execute the following commands

mysql --host mysql_slave -uroot -proot -AN -e "change master to master_host='mysql_master',master_user='repuser', master_password='reppassword', master_log_file='$Master_File', master_log_pos=$Master_Position;"

    
mysql --host mysql_slave -uroot -proot -AN -e "START SLAVE;"
