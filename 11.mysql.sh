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

dnf install mysql-server -y &>>log_file
validate $? "installing mysql"

systemctl enable mysqld &>>log_file
validate $? "enabling mysql"

systemctl start mysqld &>>log_file 
validate $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "setting up root password"
