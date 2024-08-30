#!/bin/bash

# echo "$@"
LOG_FOLDER="/var/log/shell-script"
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
                echo "please user root user " | tee -a $LOG_FILE
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

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE_PACKAGE $? "Installing MySql Serveer"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE_PACKAGE $? "Enabled MySql Serveer"

systemctl start mysqld | tee -a $LOG_FILE
VALIDATE_PACKAGE $? "Started MySql Serveer"

mysql -h 34.201.160.152 -u root -p ExpenseApp@1 -e 'show databases;' &>> $LOG_FILE
if [ $? -ne 0 ]
then 
    echo "My Sql server root password is not set up" &>> $LOG_FILE
    mysql_secure_installation --set-root-pass EpenseApp@1 &>> $LOG_FILE
    VALIDATE_PACKAGE $? "Setting Up root Password"  
else 
    echo -e "MySQL root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi
