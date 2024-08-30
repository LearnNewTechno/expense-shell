#!/bin/bash

# echo "$@"
LOG_FOLDER="/var/log/expense"
FILE_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%F_%H_%M_%S)
LOG_FILE="$LOG_FOLDER/$FILE_NAME-$TIMESTAMP.log"

echo $LOG_FILE
echo "---------------------------------------------------------"

mkdir -p $LOG_FOLDER

USER=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "started script executing at $(date)"

ROOT_USER()
{
        if [ $USER -ne 0 ]
        then
                echo -e " $R please run this script with root user " | tee -a $LOG_FILE
                exit 1
        fi
}

VALIDATE()
{
        if [ $1 -ne 0 ]
        then
                echo -e "$2 is $R  FAILED $N" | tee -a $LOG_FILE
                exit 1
        else
                echo -e "$2 is $G success $N" | tee -a $LOG_FILE
        fi
}

ROOT_USER


dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling default NodeJs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabling nodejs:20"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installed NodeJs:20"

id expense &>> $LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "Expense user not exists.. $G Creating $N"
    useradd expense &>> $LOG_FILE
    VALIDATE $?  "Created expense user"
else 
    echo -e "Expense user aready exits.. $Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "Creating /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE
VALIDATE $? "Downloading backend application code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>> $LOG_FILE
VALIDATE $? "Extraxcting backend application code"

npm install &>> $LOG_FILE


cp  /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

dnf install mysql -y  &>> $LOG_FILE

mysql -h mysql.ravijavadevops.site -uroot -pExpenseApp@1 < /app/schema/backend.sql  &>> $LOG_FILE
VALIDATE $? "Schema loading"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Daemon Reload"

systemctl enable backend  &>> $LOG_FILE
VALIDATE $? "Enable Backend"

systemctl restart backend  &>> $LOG_FILE
VALIDATE $? "Restart Backend"
