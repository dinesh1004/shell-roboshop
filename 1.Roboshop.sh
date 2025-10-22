#!binbash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0ada60f774a1d7eb8"
dns_name="suneel.shop"

for instance in $@
do
    instance_id=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    if [ $instance != "frontend" ]; then
       IP=$( aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text )
       RECORD_NAME="$instance.$dns_name"
    else
        IP=$( aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text )
        RECORD_NAME="$dns_name"
    fi

    echo "$instance : $IP"
    aws route53 change-resource-record-sets \
  --hosted-zone-id Z05339043BT9MD1FV3PVX \
  --change-batch '
  {
    "Comment": "Updating record set"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$RECORD_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
      }
    }]
  }
  '

done