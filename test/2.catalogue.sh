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
validat $? "disabling nodejs:20"

dnf install nodejs -y &>>log_file
validat $? "installing nodejs"

id roboshop &>>log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>log_file
    validate $? "adding roboshop user"
else
    echo "roboshop user is already exist"
fi 

mkdir -p /app 
validate $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>log_file
validate $? "downloading the  application"

cd /app 
validate $? "changing to app directory"

rm -rf /app/*
validate $? "removing existing code"

unzip /tmp/catalogue.zip &>>log_file
validate $? "unzipping application"

cd /app 

npm install &>>log_file
validate $? "installing dependencies"

systemctl daemon-reload
systemctl enable catalogue &>>log_file
validate $? "enabling catalogue"

systemctl start catalogue &>>log_file
validate $? "starting  catalogue"

cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo repo"

dnf install mongodb-mongosh -y &>>log_file
validate $? "installing mongod"

INDEX=$(mongosh mongodb.suneel.shop --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$log_file
    validate $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue &>>log_file
validate $? "Restarted catalogue"

