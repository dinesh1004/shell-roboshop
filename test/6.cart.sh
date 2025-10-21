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

# dnf module disable nodejs -y &>>log_file
# validate $? "disabling nodejs" 
# dnf module enable nodejs:20 -y &>>log_file
# validate $? "enabling  nodejs:20" 
# dnf install nodejs -y &>>log_file
# validate $? "installing nodejs" 

# id roboshop &>>log_file
# if [ $? -ne 0 ]; then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
#     validate $? "adding roboshop user"
# else
#     echo -e "roboshop user is already exist.........$Y SKIPPING $N"
# fi 

# mkdir -p /app 
# validate $? "creating app directory"

# rm -rf /app/*
# validate $? "re,moving old code"

# curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>log_file
# validate $? "downloading the application"
# cd /app 
# unzip /tmp/cart.zip&>>log_file
# validate $? "unzippping the application"
# cd /app 
# npm install &>>log_file
# validate $? "installing dependencies"

# # cp $script_dir/cart.service /etc/systemd/system/cart.service
# # validate $? "copying cart.services"
# cp $script_dir/cart.service /etc/systemd/system/cart.service
# validate $? "copying cart service file"

# systemctl daemon-reload

# systemctl enable cart &>>log_file
# validate $? "enabling cart"
# systemctl start cart &>>log_file
# validate $? "starting cart"

#!/bin/bash
# CRITICAL FIX 1: Corrected shebang to #!/bin/bash

userid=$( id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Log folder definition
folder="/var/log/roboshop"
# Derive script name for log file
script_name=$(basename $0)
log_file="$folder/$script_name.log"

# Create log folder and start log entry
mkdir -p $folder
echo "This script has started at: $(date)" | tee -a $log_file

# Define the directory where the script is located (where cart.service should be)
script_dir=$(dirname $0)
if [ "$script_dir" = "." ]; then
    script_dir=$PWD
fi

if [ $userid -ne 0 ]; then
    echo "ERROR: Please run the script with sudo privileges" | tee -a $log_file
    exit 1
fi

validate(){
    # Logs validation status to both console and log file
    if [ $1 -ne 0 ]; then
        echo -e "$2 is...... ${R}failed${N}" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is......${G}success${N}" | tee -a $log_file
    fi
}

# --- Installation Steps ---

# NOTE: The log redirection now correctly uses the $log_file variable.

dnf module disable nodejs -y &>>$log_file
validate $? "disabling nodejs" 

dnf module enable nodejs:20 -y &>>$log_file
validate $? "enabling nodejs:20" 

dnf install nodejs -y &>>$log_file
validate $? "installing nodejs" 

# Check for roboshop user and create if necessary
id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "adding roboshop user"
else
    echo -e "roboshop user is already exist.........${Y}SKIPPING${N}" | tee -a $log_file
fi 

# Create /app directory
mkdir -p /app 
validate $? "creating app directory"

# Remove old code
rm -rf /app/*
validate $? "removing old code"

# Download and Extract Application
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$log_file
validate $? "downloading the application"

cd /app 
unzip /tmp/cart.zip &>>$log_file
validate $? "unzipping the application"

# Install dependencies
npm install &>>$log_file
validate $? "installing dependencies"

# --- Copy and Start Service ---

# Print the source path being used for debugging the copy issue
echo "DEBUG: Copying service from: $script_dir/cart.service" | tee -a $log_file

cp $script_dir/cart.service /etc/systemd/system/cart.service
validate $? "copying cart service file"

systemctl daemon-reload
validate $? "reloading systemd daemon" # Always validate daemon-reload

systemctl enable cart &>>$log_file
validate $? "enabling cart"

systemctl start cart &>>$log_file
validate $? "starting cart"