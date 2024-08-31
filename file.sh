
#!/bin/bash


SOURCE_DIR=/home/ec2-user/logs/

R="\e[31m"
G="\e[32m"
N="\e[0m"

if [ -d $SOURCE_DIR ]
then
        echo -e "$G directory exists$N"
else
        echo -e "$R directory not exists$N"

fi
