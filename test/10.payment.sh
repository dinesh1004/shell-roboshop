# #!/bin/bash
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
# echo $script_dir

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

# dnf install python3 gcc python3-devel -y &>>log_file
# validate $? "installing python3"

# id roboshop &>>log_file
# if [ $? -ne 0 ]; then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
#     validate $? "adding roboshop user"
# else
#     echo "roboshop user is already exist"
# fi

# mkdir -p /app 
# validate $? "creating app directory"
#  rm -rf /app/*


# curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>log_file
# validate $? "downloading application"

# cd /app 

# unzip /tmp/payment.zip &>>log_file
# validate $? "unzipping application"

# cd /app 
# pip3 install -r requirements.txt &>>log_file
# validate $? "installing requirements"

# cp $script_dir/payment.service /etc/systemd/system/payment.service
# validate $? "copying payment.service"

# systemctl daemon-reload

# systemctl enable payment &>>log_file
# validate $? "enabling payment "
# systemctl start payment &>>log_file
# validate $? "starting payment"

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
MYSQL_HOST=mysql.suneel.shop

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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading payment application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzip payment"

pip3 install -r requirements.txt &>>$LOG_FILE

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
systemctl daemon-reload
systemctl enable payment  &>>$LOG_FILE

systemctl restart payment