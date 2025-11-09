🧱 Step 1: Create the ALB Security Group
aws ec2 create-security-group \
  --group-name ALB-SG \
  --description "Security group for Application Load Balancer" \
  --vpc-id <YOUR-VPC-ID>

  "GroupId": "sg-0e46e421f18e35739"

🌐 Step 2: Allow Inbound HTTP (Port 80) from Anywhere
aws ec2 authorize-security-group-ingress \
  --group-id <ALB-SG-ID> \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0


This allows HTTP requests from any IP (i.e., from the internet).

🚀 Step 3: Allow All Outbound Traffic

By default, AWS Security Groups allow all outbound traffic,
so you don’t need to explicitly add this rule unless you’ve modified defaults.

But to be explicit:

aws ec2 authorize-security-group-egress \
  --group-id <ALB-SG-ID> \
  --protocol -1 \
  --port all \
  --cidr 0.0.0.0/0


🧱 Step 1: Create the Backend Security Group
aws ec2 create-security-group \
  --group-name Backend-SG \
  --description "Security group for backend instances" \
  --vpc-id <YOUR-VPC-ID>

"GroupId": "sg-032b057e216eac116"

🔗 Step 2: Allow Inbound Traffic from ALB-SG (Port 5000)

Now you’ll link ALB-SG → Backend-SG, meaning:

Only traffic from the ALB is allowed to reach backend instances on port 5000.

Run this:

aws ec2 authorize-security-group-ingress \
  --group-id <BACKEND-SG-ID> \
  --protocol tcp \
  --port 5000 \
  --source-group <ALB-SG-ID>


✅ Replace:

<BACKEND-SG-ID> → the GroupId from step 1

<ALB-SG-ID> → the GroupId from your ALB-SG created earlier

This ensures no one on the internet can directly hit your backend —
only requests that come through your ALB are allowed.

🌐 Step 3: Allow All Outbound Traffic (Default)

Usually, AWS Security Groups already allow all outbound traffic,
but to make it explicit:

aws ec2 authorize-security-group-egress \
  --group-id <BACKEND-SG-ID> \
  --protocol -1 \
  --port all \
  --cidr 0.0.0.0/0

🧩 Step 1: Create RDS Security Group
aws ec2 create-security-group \
  --group-name RDS-SG \
  --description "RDS security group allowing MySQL access from Backend-SG" \
  --vpc-id <VPC-ID>

 "GroupId": "sg-0d37a6e2e3954bc36"

🧩 Step 2: Allow inbound traffic from Backend-SG
aws ec2 authorize-security-group-ingress \
  --group-id <RDS-SG-ID> \
  --protocol tcp \
  --port 3306 \
  --source-group <BACKEND-SG-ID>


Replace:

<RDS-SG-ID> → ID returned from step 1

<BACKEND-SG-ID> → your backend security group ID

This allows only your backend instances to connect to RDS on port 3306.