Phase 5 — CI/CD with CodePipeline + CodeBuild + CodeDeploy

You already have:

✅ Backend code on GitHub

✅ EC2 instances in ASG (Auto Scaling Group)

✅ Backend running via launch template

✅ RDS, S3, ALB configured

Now we’ll make AWS automatically build and deploy your app every time you push new code to GitHub.

⚙️ Overall Flow
GitHub Push → CodePipeline → CodeBuild → CodeDeploy → EC2 (via ASG)

🧩 Step-by-Step Setup
1️⃣ Create IAM Roles

We need three service roles:

(a) CodePipeline Role
aws iam create-role \
  --role-name CodePipelineServiceRole \
  --assume-role-policy-document file://<(echo '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "codepipeline.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }')
Attaching Policies
----------------------

aws iam attach-role-policy --role-name CodePipelineServiceRole \
  --policy-arn arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess
aws iam attach-role-policy --role-name CodePipelineServiceRole \
  --policy-arn arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess
aws iam attach-role-policy --role-name CodePipelineServiceRole \
  --policy-arn arn:aws:iam::aws:policy/AWSCodeDeployFullAccess

(b) CodeBuild Role
aws iam create-role \
  --role-name CodeBuildServiceRole \
  --assume-role-policy-document file://<(echo '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "codebuild.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }')


Attach policies:

aws iam attach-role-policy --role-name CodeBuildServiceRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name CodeBuildServiceRole \
  --policy-arn arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess
aws iam attach-role-policy --role-name CodeBuildServiceRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

(c) CodeDeploy Role (for EC2 instances)

This you already likely have from your backend ASG setup.

If not:

aws iam create-role \
  --role-name CodeDeployEC2Role \
  --assume-role-policy-document file://<(echo '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }')

aws iam attach-role-policy --role-name CodeDeployEC2Role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy

arn:aws:codeconnections:us-east-1:289259597484:connection/c5e15727-ec6d-4965-90e2-8ff483d506f6

2️⃣ Configure GitHub Source

Go to AWS CodePipeline → Settings → Connections → Create Connection

Choose GitHub (Version 2)

Authorize AWS to access your GitHub

Note the Connection ARN

arn:aws:codeconnections:us-east-1:289259597484:connection/c5e15727-ec6d-4965-90e2-8ff483d506f6


4️⃣ Create CodeBuild Project
aws codebuild create-project \
  --name backend-build \
  --source type=CODEPIPELINE \
  --artifacts type=CODEPIPELINE \
  --environment type=LINUX_CONTAINER,image=aws/codebuild/standard:5.0,computeType=BUILD_GENERAL1_SMALL,environmentVariables=[{name=ENV,value=prod}] \
  --service-role arn:aws:iam::<YOUR_ACCOUNT_ID>:role/CodeBuildServiceRole

5️⃣ Create CodeDeploy Application + Deployment Group

If not already:

aws deploy create-application --application-name backend-app --compute-platform Server

Then create a deployment group:

aws deploy create-deployment-group \
  --application-name backend-app \
  --deployment-group-name backend-dg \
  --service-role-arn arn:aws:iam::<YOUR_ACCOUNT_ID>:role/CodeDeployServiceRole \
  --auto-scaling-groups backend-asg \
  --deployment-style deploymentType=BLUE_GREEN,deploymentOption=WITH_TRAFFIC_CONTROL