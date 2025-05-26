#!/bin/bash
source ./common.sh
app=cart

check_root
app_setup

nodejs_setup
systemd_setup

print_time

#$mongosh --host mongodb.daws84s.space </app/db/master-data.js &>>$LOG_FILE
#VALIDATE $? "loding data into mongdb"

#STATUS=$(mongosh --host mongodb.daws84s.site --eval 'db.getMongo().getDBNames().indexOf("cart")')
#if [ $STATUS -lt 0 ]
#then
#    mongosh --host mongodb.daws84s.site </app/db/master-data.js &>>$LOG_FILE
#    VALIDATE $? "Loading data into MongoDB"
#else
#    echo -e "Data is already loaded ... $Y SKIPPING $N"
#fi