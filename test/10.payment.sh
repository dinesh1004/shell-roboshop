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

dnf install python3 gcc python3-devel -y &>>log_file
validate $? "installing python3"

id roboshop &>>log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "adding roboshop user"
else
    echo "roboshop user is already exist"
fi

mkdir -p /app 
validate $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>log_file
validate $? "downloading application"
cd /app 
unzip /tmp/payment.zip &>>log_file
validate $? "unzipping application"
cd /app 
pip3 install -r requirements.txt &>>log_file
validate $? "installing requirements"

cp $script_dir/payment.service /etc/systemd/system/payment.service
validate $? "copying payment.service"

systemctl daemon-reload

systemctl enable payment &>>log_file
validate $? "enabling payment "
systemctl start payment &>>log_file
validate $? "starting payment"