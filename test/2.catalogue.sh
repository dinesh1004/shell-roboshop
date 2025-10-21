# #!binbash
# userid=$( id -u)
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"
# folder="/var/log/mongodb-log"
# script=$( echo $0)
# script_dir=($PWD)
# echo $script_dir
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

# dnf module disable nodejs -y &>>log_file
# validate $? "disabling nodejs"

# dnf module enable nodejs:20 -y &>>log_file
# validate $? "enabling nodejs:20"

# dnf install nodejs -y &>>log_file
# validate $? "installing nodejs"

# id roboshop
# if [ $? -ne 0 ]; then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
#     validate $? "adding roboshop user"
# else
#     echo -e "roboshop user is already exist........$Y skipping $N"
# fi


# mkdir -p /app 
# validate $? "creating app directory"

# curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>log_file
# validate $? "downloading the application"

# cd /app 

# rm -rf /app/*
# validate $? "Removing existing code"

# unzip /tmp/catalogue.zip -d &>>log_file
# validate $? "unzipping application"

# npm install -y &>>log_file
# validate $? "installing dependencies"

# cp $script_dir/catalogue.service /etc/systemd/system/catalogue.service

# systemctl daemon-reload

# systemctl enable catalogue &>>log_file
# validate $? "enabling catalogue service"

# systemctl start catalogue &>>log_file
# validate $? "starting catalogue service"

#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws86s.fun
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

##### NodeJS ####
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading catalogue application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enable catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install MongoDB client"

INDEX=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarted catalogue"
