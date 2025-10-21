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

cp $script_dir/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "copying rabbitmq repo"

dnf install rabbitmq-server -y &>>log_file
validate $? "installing rabbitmq server"
systemctl enable rabbitmq-server &>>log_file
validate $? "enabling rabbitmq server"
systemctl start rabbitmq-server &>>log_file
validate $? "starting rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>>log_file
validate $? "adding roboshop user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>log_file
validate $? "setting up permissions"