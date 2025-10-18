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
echo "$(script_dir)"
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
dnf module enable nodejs:20 -y  &>>log_file
dnf install nodejs -y &>>log_file
validate $? "installation of nodejs"

id roboshop &>>log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>log_file
    validate $? "adding user"
else
    echo -e "roboshop user is already exist.....$Y skipping $N"
fi

mkdir /app 

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>log_file
validate $? "downloading the application"

cd /app 

unzip /tmp/user.zip
validate $? "unzipping the application"

cd /app 
npm install &>>log_file
validate $? "installation of npm"

cp $script_dir/user.service /etc/systemd/system/user.service

systemctl daemon-reload

systemctl enable user 
validate $? "enabling user"

systemctl start user
validate $? "starting user"