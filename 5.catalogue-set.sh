#!binbash
set -euo Pipefail

trap 'echo "ther is an error in $LINENO, command is $BASH_COMMAND"' ERR
userid=$( id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
folder="/var/log/mongodb-log"
script=$( echo $0 | cut -d "." -f2 )
log_file="$folder/$script.log"
mkdir -p $folder
directory=$PWD
echo $directory
mongodb_host=mongodb.suneel.shop
echo "this scrip has started at : $(date)"
if [ $userid -ne 0 ]; then
    echo "ERROR please run the script with sudo privillages"
    exit 1
fi
# validate(){
#     if [ $1 -ne 0 ]; then
#         echo -e "$2 is...... $R failed $N" | tee -a $log_file
#         exit 1
#     else
#         echo -e "$2 is......$G success $N" | tee -a $log_file
#     fi
# }

dnf module disable nodejs -y &>>$log_file


dnf module enable nodejs:20 -y &>>$log_file


dnf install nodejs -y &>>$log_file


id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   
else
    echo -e "user is alrady exist.......$Y SKIPPING $N"
fi

mkdir -p /app &>>$log_file


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log_file


cd /app 

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$log_file

npm install &>>$log_file

cp $directory/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload

systemctl enable catalogue &>>$log_file

systemctl start catalogue &>>$log_file

cp $directory/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>>$log_file

INDEX=$(mongosh $mongodb_host --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
echo $INDEX
if [ $INDEX -le 0 ]; then
    mongosh --host $mongodb_host </app/db/master-data.js &>>$log_file
   
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
