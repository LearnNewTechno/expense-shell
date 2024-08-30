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

dnf install nginx -y  &>> $LOG_FILE
VALIDATE $? "installing NGINX"

systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "Enable NGINX"

systemctl start nginx &>> $LOG_FILE
VALIDATE $? "Start NGINX"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
VALIDATE $? "Removing default weg site"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip  &>> $LOG_FILE
VALIDATE $? "Downloadin front end code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip  &>> $LOG_FILE
VALIDATE $? "Extract front End code"

cp  /home/ec2-user/expense-shell/expense.config /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied Expense config"

systemctl restart nginx