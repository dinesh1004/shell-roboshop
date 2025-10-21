#!binbash
userid=$( id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
folder="/var/log/mongodb-log"
script=$( echo $0)
script_dir=($PWD)
echo $script_dir
log_file="$folder/$script.log"
mkdir -p $folder
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
validate $? "enabling nodejs:20"

dnf install nodejs -y &>>log_file
validate $? "installing nodejs"

id roboshop
if [ $? -ne 0]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "adding roboshop user"
else
    echo -e "roboshop user is already exist........$Y skipping $N"
fi


mkdir -p /app 
validate $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>log_file
validate $? "downloading the application"

cd /app 

unzip /tmp/catalogue.zip &>>log_file
validate $? "unzipping application"

npm install -y &>>log_file
validate $? "installing dependencies"

cp $script_dir/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload

systemctl enable catalogue &>>log_file
validate $? "enabling catalogue service"

systemctl start catalogue &>>log_file
validate $? "starting catalogue service"
