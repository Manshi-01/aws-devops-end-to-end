Create user_data.sh

This script installs and runs your Flask app on EC2 startup.

📄 backend/user_data.sh

#!/bin/bash
sudo apt update -y
sudo apt install -y python3-pip

# Create backend app directory
mkdir -p /home/ubuntu/backend
cd /home/ubuntu/backend

# Create Flask app
cat <<EOF > app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Manshi's Flask backend running on EC2 via ALB!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Install Flask and run the app
pip3 install flask
nohup python3 app.py > app.log 2>&1 &

🧱 Step 4 — Create Launch Template

This defines your EC2 app template for the Auto Scaling Group.

aws ec2 create-launch-template \
  --launch-template-name backend-launch-template \
  --version-description "v1" \
  --launch-template-data '{
    "ImageId": "ami-0ecb62995f68bb549",
    "InstanceType": "t2.micro",
    "KeyName": "devops_key",
    "SecurityGroupIds": ["<BACKEND-SG-ID>"],
    "UserData": "'"$(base64 -w0 backend/user_data.sh)"'",
    "TagSpecifications": [{
      "ResourceType": "instance",
      "Tags": [{"Key": "Name", "Value": "backend-ec2"}]
    }]
  }'

ID :  lt-0730f3da8b9f9ebcc


🧩 Step 5 — Create Target Group

This will route requests from the ALB to EC2 instances.

aws elbv2 create-target-group \
  --name backend-tg \
  --protocol HTTP \
  --port 5000 \
  --vpc-id <VPC-ID> \
  --target-type instance \
  --health-check-path "/" \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --healthy-threshold-count 3 \
  --unhealthy-threshold-count 3

 "TargetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:289259597484:targetgroup/backend-tg/c7c586f0da39f654"

 🌐 Step 6 — Create Application Load Balancer (ALB)

Create ALB in public subnets.

aws elbv2 create-load-balancer \
  --name backend-alb \
  --subnets <PUBLIC-SUBNET-1-ID> <PUBLIC-SUBNET-2-ID> \
  --security-groups <ALB-SG-ID> \
  --scheme internet-facing \
  --type application

"LoadBalancerArn": "arn:aws:elasticloadbalancing:us-east-1:289259597484:loadbalancer/app/backend-alb/717c7bddcbd873a6"

🔀 Step 7 — Create Listener (Port 80 → Target Group)
aws elbv2 create-listener \
  --load-balancer-arn <ALB-ARN> \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=<TARGET-GROUP-ARN>

 "ListenerArn": "arn:aws:elasticloadbalancing:us-east-1:289259597484:listener/app/backend-alb/717c7bddcbd873a6/82bd04ede7321eb5"


⚙️ Step 8 — Create Auto Scaling Group (ASG)

Now we’ll use the Launch Template and Target Group to create the ASG.

aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name backend-asg \
  --launch-template LaunchTemplateName=backend-launch-template,Version=1 \
  --min-size 1 \
  --max-size 3 \
  --desired-capacity 1 \
  --vpc-zone-identifier "<PRIVATE-SUBNET-1-ID>,<PRIVATE-SUBNET-2-ID>" \
  --target-group-arns <TARGET-GROUP-ARN>

  #Everytime any defects comes, for the correct version the version of launch template as well asg changes , so we give Version=$latest

🧾 Step 9 — Verify Deployment
Check ALB DNS
aws elbv2 describe-load-balancers --names backend-alb \
  --query "LoadBalancers[*].DNSName" --output text


Open the URL in your browser:

http://<ALB-DNS-NAME>
backend-alb-1618331575.us-east-1.elb.amazonaws.com

If healthy ✅ you’ll see:

Hello from Manshi's Flask backend running on EC2 via ALB!

Steps to fix the issue
-----------------------
Run this command to get the latest version number:

aws ec2 describe-launch-templates \
  --launch-template-names backend-launch-template \
  --query "LaunchTemplates[0].LatestVersionNumber" \
  --output text

Then run again the launch template and asg commands