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

cp mongodb.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongodb repo"

dnf install mongodb-org -y 
validate $? "installing mongodb"

systemctl enable mongod 
validate $? "ienabling mongodb" 

systemctl start mongod 
validate $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "alloeing remote connections to mongodb"

systemctl restart mongod
validate $? "restarting mongodb"