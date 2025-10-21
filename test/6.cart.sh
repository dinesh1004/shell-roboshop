#!binbash
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

dnf module disable nodejs -y &>>log_file
validate $? "disabling nodejs" 
dnf module enable nodejs:20 -y &>>log_file
validate $? "enabling  nodejs:20" 
dnf install nodejs -y &>>log_file
validate $? "installing nodejs" 

id roboshop &>>log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "adding roboshop user"
else
    echo -e "roboshop user is already exist.........$Y SKIPPING $N"
fi 

mkdir -p /app 
validate $? "creating app directory"

rm -rf /app/*
validate $? "re,moving old code"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>log_file
validate $? "downloading the application"
cd /app 
unzip /tmp/cart.zip&>>log_file
validate $? "unzippping the application"
cd /app 
npm install &>>log_file
validate $? "installing dependencies"

cp $script_dir/cart.service /etc/systemd/system/cart.service
validate $? "copying cart.services"

systemctl daemon-reload

systemctl enable cart &>>log_file
validate $? "enabling cart"
systemctl start cart &>>log_file
validate $? "starting cart"