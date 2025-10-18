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
mysql_host=mysql.suneel.shop
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

dnf install maven -y &>>log_file

id roboshop 
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>log_file
    validate $? "adding system user"
else 
    echo " user is already added.....$Y SKIPPING $N"
fi 

mkdir -p /app 
validate $? "creating app directory"
 
rm -rf /app/* 
validate $? "removing existing code"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>log_file
validate $? "downloading application"

cd /app 

unzip /tmp/shipping.zip &>>log_file
validate $? "unzipping app"
cd /app 
mvn clean package &>>log_file

mv target/shipping-1.0.jar shipping.jar 

cp $script_dir/shipping.service /etc/systemd/system/shipping.service

systemctl enable shipping &>>log_file
systemctl start shipping &>>log_file

dnf install mysql -y &>>log_file
validate $? "installing MYsql"

mysql -h mysql.suneel.shop -uroot -pRoboShop@1 -p -e 'use cities'
if [ $? -ne 0 ]; then 
    mysql -h mysql.suneel.shop -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h mysql.suneel.shop -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h mysql.suneel.shop -uroot -pRoboShop@1 < /app/db/master-data.sql
else 
    echo " all cities data is already loaded in to DB....$Y KIPPING $N"
fi 

systemctl restart shipping &>>log_file
validate $? "rastarting shipping"
