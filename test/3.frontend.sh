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
# script_dir=$PWD
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

# dnf module disable nginx -y &>>log_file
# validate $? "disabling nginx"

# dnf module enable nginx:1.24 -y &>>log_file
# validate $? "disablenabling ing nginx:1.24"

# dnf install nginx -y &>>log_file
# validate $? "installing nginx"

# systemctl enable nginx &>>log_file
# validate $? "enabling nginx"


# systemctl start nginx &>>log_file
# validate $? "starting nginx"

# rm -rf /usr/share/nginx/html/* 
# validate $? "removing default content"

# curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>log_file
# validate $? "downloading application"

# cd /usr/share/nginx/html 
# unzip /tmp/frontend.zip &>>log_file
# validate $? "unzipping application"

# cp $script_dir/nginx.conf /etc/nginx/nginx.conf
# validate $? "copying nginx.conf"

# systemctl restart nginx &>>log_file
# validate $? "restarting nginx"


#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST=172.31.24.123
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

dnf module disable nginx -y &>>$LOG_FILE
dnf module enable nginx:1.24 -y &>>$LOG_FILE
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx 
VALIDATE $? "Restarting Nginx"

