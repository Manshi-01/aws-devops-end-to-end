aws ec2 create-vpc --cidr-block 10.0.0.0/16
"VpcId": "vpc-08845d77d95306902",

aws sts get-caller-identity

Public Subnet 1
aws ec2 create-subnet \
  --vpc-id vpc-08845d77d95306902 \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a

   "SubnetId": "subnet-0fb634552b7821b86"

Public Subnet 2
aws ec2 create-subnet \
  --vpc-id <VPC-ID> \
  --cidr-block 10.0.2.0/24 \
  --availability-zone us-east-1b

  

  "SubnetId": "subnet-0735ee73893f46b5e"

Private Subnet 1
aws ec2 create-subnet \
  --vpc-id <VPC-ID> \
  --cidr-block 10.0.3.0/24 \
  --availability-zone us-east-1a

   "SubnetId": "subnet-08460a1769d475a18"

Private Subnet 2
aws ec2 create-subnet \
  --vpc-id <VPC-ID> \
  --cidr-block 10.0.3.0/24 \
  --availability-zone us-east-1a

 "SubnetId": "subnet-0bbd2a0ab82ba99ef"

Internet Gateway
-----------------

aws ec2 create-internet-gateway

=> "InternetGatewayId": "igw-0c1f8a2c60c39bcb5"

Attaching IGW to the VPC
----------------------------
aws ec2 attach-internet-gateway --vpc-id vpc-08845d7
7d95306902 --internet-gateway-id igw-0c1f8a2c60c39bcb5


