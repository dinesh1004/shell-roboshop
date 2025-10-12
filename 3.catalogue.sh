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
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 is...... $R failed $N" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is......$G success $N" | tee -a $log_file
    fi
}

dnf module disable nodejs -y &>>$log_file
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
validate $? "enabling nodejs"

dnf install nodejs -y &>>$log_file
validate $? "installing nodejs"

id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating system user"
else
    echo -e "user is alrady exist.......$y SKIPPING $N"
fi

mkdir -p /app 
validate $? "creating app"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
validate $? "downloading zip file"

cd /app 
validate $? "changing directory to app"

rm -rf /app/*
validate $? "cremoving existing code from app"

unzip /tmp/catalogue.zip
validate $? "unzipping"

npm install &>>$log_file
validate $? "installing dependencies"

cp $directory/catalogue.service /etc/systemd/system/catalogue.service
validate $? "copying catalogue services"

systemctl daemon-reload

systemctl enable catalogue &>>$log_file
validate $? "enabling catalogue"

systemctl start catalogue &>>$log_file
validate $? "starting catalogue"

cp $directory/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copy mongo repo"

dnf install mongodb-mongosh -y &>>$log_file
validate $? "installing mongoDB client"

INDEX=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $mongodb_host </app/db/master-data.js
    validate $? "load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarted catalogue"