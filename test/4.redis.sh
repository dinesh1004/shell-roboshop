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

dnf module disable redis -y &>>log_file
validate $? "disabling redis"
dnf module enable redis:7 -y &>>log_file
validate $? "enabling  redis:7"
dnf install redis -y &>>log_file
validate $? "installing  redis"

sed -i 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate $? "allowing external traffic"

systemctl enable redis &>>log_file
validate $? "enabling  redis"

systemctl start redis &>>log_file
validate $? "restarting  redis"
