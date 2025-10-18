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
dnf install python3 gcc python3-devel -y &>>log_file
validate $? "installing python3"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "adding roboshop user"
else
    echo "roboshop user already exist"
fi

mkdir -p /app 
validate $? "creating app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
validate $? "adownloading application"


cd /app 
unzip /tmp/payment.zip
validate $? "aunzipping application"

cd /app 

pip3 install -r requirements.txt
validate $? "installing requirements"

cp $script_dir/payment.service /etc/systemd/system/payment.service

systemctl daemon-reload
systemctl enable payment 
validate $? "enabling payment"

systemctl start payment
validate $? "starting payment"