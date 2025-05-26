#!/bin/bash
START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD


mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not



print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))

    echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
}

check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1 #give other than 0 upto 127
    else
        echo "You are running with root access" | tee -a $LOG_FILE
    fi
}


app_setup(){
    id roboshop
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop    
        VALIDATE $? "creating roboshop system user"
    else 
        echo -e "system user roboshop alraedy cretaed .... $Y skipping $N"
    fi    
    
    mkdir -p /app 
    VALIDATE $? "careating app  directory"


    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/-v3.zip  &>>$LOG_FILE
    VALIDATE $? "Dowlinding $app_name"

    rm -rf /app/*
    cd /app 

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzipping  $app_name"
}

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disabling default nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "enablinh nodejs"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "insatalling nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $?  "installing dependies"

}

system_setup(){
    cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
    VALIDATE $? "copy the calalogue service"
    
    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable catalogue  &>>$LOG_FILE
    systemctl start catalogue
    VALIDATE $? "starting catalogue"
}