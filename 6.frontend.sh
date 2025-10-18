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
script_dir=$PWD
echo "$script_dir"
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
dnf module enable nginx:1.24 -y &>>log_file
dnf install nginx -y &>>log_file
validate $? "installing nginx"

systemctl enable nginx &>>log_file
validate $? "enabling nginx"
systemctl start nginx 
validate $? "starting nginx"

rm -rf /usr/share/nginx/html/* 

validate $? "removing default content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>log_file
validate $? "downloading application"

cd /usr/share/nginx/html 

unzip /tmp/frontend.zip &>>log_file
validate $? "unzipping the application"

rm -rf /etc/nginx/nginx.conf

cp $script_dir/nginx.conf /etc/nginx/nginx.conf
validate $? "copying  nginx.conf"

systemctl restart nginx 
validate $? "restarting  nginx"