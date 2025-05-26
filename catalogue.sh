#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup

system_setup


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing Mongodb client"



#$mongosh --host mongodb.daws84s.space </app/db/master-data.js &>>$LOG_FILE
#VALIDATE $? "loding data into mongdb"

STATUS=$(mongosh --host mongodb.daws84s.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.daws84s.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi

total_time=$((end_time - start_time))
echo  -e "Total execution time:   Y $total_time seconds" $N | tee -a &>>$LOG_FILE

print_time