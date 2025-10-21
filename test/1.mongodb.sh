# #!binbash
# userid=$( id -u)
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"
# folder="/var/log/mongodb-log"
# script=$( echo $0)
# log_file="$folder/$script.log"
# mkdir -p $folder
# echo "this scrip has started at : $(date)"
# if [ $userid -ne 0 ]; then
#     echo "ERROR please run the script with sudo privillages"
#     exit 1
# fi
# validate(){
#     if [ $1 -ne 0 ]; then
#         echo -e "$2 is...... $R failed $N" | tee -a $log_file
#         exit 1
#     else
#         echo -e "$2 is......$G success $N" | tee -a $log_file
#     fi
# }

# cp mongo.repo /etc/yum.repos.d/mongo.repo
# validate $? "copying mongodb repo"

# dnf install mongodb-org -y &>>log_file
# validate $? "installing mongodb"

# systemctl enable mongod &>>log_file
# validate $? "ienabling mongodb" 

# systemctl start mongod &>>log_file
# validate $? "starting mongodb"

# sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.confs
# validate $? "allowing remote connections to mongodb"

# systemctl restart mongod &>>log_file
# validate $? "restarting mongodb"

#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enable MongoDB"

systemctl start mongod 
VALIDATE $? "Start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"