#!/bin/bash


acc=$(aws sts get-caller-identity --query "Account" --output text)

echo "Script By VaiS / fetching" $1 "from: $acc" 


getVpc () {
    aws ec2 describe-vpcs --vpc-ids $1 --region eu-west-1 --output json
}

getRds () {
    aws rds describe-db-instances --db-instance-identifier $1 --query "DBInstances[*].{
    Endpoint: Endpoint.Address,
    EngineVersion: EngineVersion,
    VPCId: DBSubnetGroup.VpcId,
    SecurityGroups: VpcSecurityGroups[*].VpcSecurityGroupId,
    ParameterGroup: DBParameterGroups[0].DBParameterGroupName,
    Subnets: DBSubnetGroup.Subnets[*].SubnetIdentifier,
    AccountID: 'AccountID'
  }" 
  --output json
}

getS3 () {
    aws s3api list-buckets --query "Buckets[?Name=='$1']"

    versioning=$(aws s3api get-bucket-versioning --bucket "$bucket_name" --query "Status" --output text 2>/dev/null || echo "Disabled")
    echo "Versioning: $versioning"

    logging=$(aws s3api get-bucket-logging --bucket "$bucket_name" --query "LoggingEnabled" --output json 2>/dev/null || echo "Logging not enabled")
    echo "Logging: $logging"

}

getSg () {
    aws ec2 describe-security-groups --group-ids $1 --query "SecurityGroups[*].{ID:GroupId,Name:GroupName,VPC:VpcId,Ingress:IpPermissions, Egress:IpPermissionsEgress}" --output json
}

getSubs () {
    aws ec2 describe-subnets --subnet-ids $1 --query "Subnets[0].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock,VPCID:VpcId,VPCName:Tags[?Key=='Name'].Value | [0]}" --output table

}


case $1 in 
    vpc)
      getVpc $2
      ;;
    
    rds)
      getRds $2
      ;;
    
    s3)
      getS3 $2
      ;;
     
    sg)
      getSg $2
      ;;
    
    subnet)
      getSubs $2
      ;;
    
    *)
      echo "Invalid option. Please use vpc, rds, s3, sg, or subnet."
      ;;
esac



