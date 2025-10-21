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

dnf module disable nginx -y &>>log_file
validate $? "disabling nginx"

dnf module enable nginx:1.24 -y &>>log_file
validate $? "disablenabling ing nginx:1.24"

dnf install nginx -y &>>log_file
validate $? "installing nginx"

systemctl enable nginx &>>log_file
validate $? "enabling nginx"


systemctl start nginx &>>log_file
validate $? "starting nginx"

rm -rf /usr/share/nginx/html/* 
validate $? "removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>log_file
validate $? "downloading application"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>log_file
validate $? "unzipping application"

cp $script_dir/nginx.conf /etc/nginx/nginx.conf
validate $? "copying nginx.conf"

systemctl restart nginx &>>log_file
validate $? "restarting nginx"




