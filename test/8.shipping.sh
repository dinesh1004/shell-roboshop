#!/bin/bash
userid=$( id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
folder="/var/log/mongodb-log"
script=$( echo $0)
log_file="$folder/$script.log"
mkdir -p $folder
script_dir=$PWD
echo $script_dir

echo "this scrip has started at : $(date)"
if [ $userid -ne 0 ]; then
    echo "ERROR please run the script with sudo privillages"
    exit 1
fi
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 is...... $R failed $N" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is......$G success $N" | tee -a $log_file
    fi
}

dnf install maven -y &>>log_file
validate $? "installing maven"

id roboshop &>>log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "adding roboshop user"
else
    echo "roboshop user is already exist"
fi

mkdir -p /app 
validate $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>log_file
validate $? "downloading application" 

cd /app 

rm -rf /app/*
validate $? "removing old code"

unzip /tmp/shipping.zip &>>log_file
validate $? "unzipping application"

cd /app 
mvn clean package &>>log_file

mv target/shipping-1.0.jar shipping.jar 

cp $script_dir/shipping.service /etc/systemd/system/shipping.service
validate $? "copying shipping.services"

systemctl daemon-reload 
systemctl enable shipping &>>log_file
validate $? "enabling shipping"
systemctl start shipping &>>log_file
validate $? "start shipping"
dnf install mysql -y  &>>log_file
validate $? "installing mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>log_file
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>log_file
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>log_file
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>log_file
else
    echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
fi

systemctl restart shipping &>>log_file
validate $? "restarting shipping"