#!binbash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0ada60f774a1d7eb8"

for instance in $@
do
    instance_id=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0ada60f774a1d7eb8 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=test }]" --query 'Instances[0].InstanceId' --output text)
    if [ $instance != "frontend" ]; then
       IP=$( aws ec2 describe-instances --instance-ids $instane_id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text )
    else
        IP=$( aws ec2 describe-instances --instance-ids $instane_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text )
    fi

    echo $instance : $IP

done
