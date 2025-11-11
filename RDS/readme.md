Step 1️⃣: Security Group for RDS

RDS should be accessible only by your backend EC2, never public.

# 1. Create Security Group for RDS
aws ec2 create-security-group \
    --group-name backend-db-sg \
    --description "RDS access from backend EC2 only" \
    --vpc-id <your-vpc-id>

aws ec2 create-security-group --group-name backend-db-sg --description "RDS access from backend EC2 only" --vpc-id vpc-08845d77d95306902
{
    "GroupId": "sg-07aeaa0eca9330ec7"
}

Create Backend EC2 Security Group
# 1️⃣ Create SG for Backend EC2
aws ec2 create-security-group \
    --group-name backend-ec2-sg \
    --description "Security Group for Backend EC2" \
    --vpc-id <your-vpc-id>

"GroupId": "sg-0150901d44ec53050"



Launch RDS MySQL Instance

aws rds create-db-instance \
    --db-instance-identifier backend-db \
    --db-name mydb \
    --allocated-storage 20 \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0.44 \
    --master-username admin \
    --master-user-password Admin1234! \
    --vpc-security-group-ids sg-07aeaa0eca9330ec7 \
    --db-subnet-group-name private-subnet-group \
    --no-publicly-accessible \
    --backup-retention-period 7

Step 1: Check RDS Status

RDS takes 5–10 minutes to become available. You can monitor it:

aws rds describe-db-instances \
    --db-instance-identifier backend-db \
    --query "DBInstances[0].DBInstanceStatus" \
    --output text


Returns creating → eventually available


Get RDS Endpoint 
aws rds describe-db-instances \
    --db-instance-identifier backend-db \
    --query "DBInstances[0].Endpoint.Address" \
    --output text
backend-db.colk4ygag7lm.us-east-1.rds.amazonaws.com