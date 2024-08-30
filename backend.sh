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

VALIDATE_PACKAGE()
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
VALIDATE_PACKAGE $? "Disabling default NodeJs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE_PACKAGE $? "Enabling nodejs"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE_PACKAGE $? "Installed Node js 20"

id expense &>> $LOG_FILE
if [ $? -ne 0 ]
then
    echo "Expense user not exists.. $G Creating $N"
    useradd expense
    echo "Created expense user"
else 
    echo -e "Expense user aready exits.. $Y Skipping $N"
fi


