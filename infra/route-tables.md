aws ec2 create-route-table --vpc-id <VPC-ID>

Add a route to IGW:
-----------------------
aws ec2 create-route \
  --route-table-id <PUBLIC-RT-ID> \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id <IGW-ID>

Here, while I was creating this, I gave the route table id , by goin to the aws frontend and thrn checking the vpc , and that vpc was already associated with the route tavble, we added a new route entry inside an existing route table (ID rtb-0ffb89a641e946e62).

Specifically,  added this rule:

Destination	Target
0.0.0.0/0	igw-0c1f8a2c60c39bcb5

🧠 Meaning

You told AWS:

“Whenever an instance in a subnet associated with this route table wants to reach any IP on the internet (0.0.0.0/0), send that traffic through the Internet Gateway (igw-0c1f8a2c60c39bcb5).”

So effectively, you made that route table “public”, meaning subnets linked to it now have internet access.

-------------------------------------------

Associate it with both public subnets:

aws ec2 associate-route-table \
  --route-table-id <PUBLIC-RT-ID> \
  --subnet-id <PUBLIC-SUBNET-1-ID>

aws ec2 associate-route-table \
  --route-table-id <PUBLIC-RT-ID> \
  --subnet-id <PUBLIC-SUBNET-2-ID>


  Enable Auto-assign Public IP for Public Subnets
-----------------------------------------------
aws ec2 modify-subnet-attribute \
  --subnet-id <PUBLIC-SUBNET-1-ID> \
  --map-public-ip-on-launch

aws ec2 modify-subnet-attribute \
  --subnet-id <PUBLIC-SUBNET-2-ID> \
  --map-public-ip-on-launch


  What NAT Gateway Does?
  Private EC2 → NAT Gateway → Internet → (download packages)
But no one from the internet can directly reach those EC2s.


1️⃣ Create an Elastic IP
aws ec2 allocate-address --domain vpc


=> You’re reserving a public IP (Elastic IP) that will be attached to your NAT Gateway.

=> Think of this as giving the NAT Gateway a fixed internet-facing address.

{
    "PublicIp": "67.202.18.216",
    "AllocationId": "eipalloc-07c1bbcf18acf14a0",
    "PublicIpv4Pool": "amazon",
    "NetworkBorderGroup": "us-east-1",
    "Domain": "vpc"
}

2️⃣ Create the NAT Gateway

aws ec2 create-nat-gateway --subnet-id subnet-0fb634552b7821b86 --allocation-id eipalloc-07c1bbcf18acf14a0

You’re creating the NAT Gateway inside a public subnet, so it can reach the internet.

You attach the Elastic IP from the previous step.

Now your NAT Gateway has a public identity and can forward requests.

Create a Private Route Table
aws ec2 create-route-table --vpc-id <VPC-ID>


Each subnet in AWS must be linked to a route table that tells traffic where to go.

You’re creating a separate route table for private subnets, since their traffic should go via NAT (not IGW).

aws ec2 create-route-table --vpc-id vpc-08845d77d95306902
{
    "RouteTable": {
        "Associations": [],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-0c18f64ddbd99b130",
        "Routes": [
            {
                "DestinationCidrBlock": "10.0.0.0/16",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [],
        "VpcId": "vpc-08845d77d95306902",
        "OwnerId": "289259597484"
    }
}

Getting NAT Gateway ID

aws ec2 describe-nat-gateways --query "NatGateways[*].{ID:NatGatewayId,Subnet:SubnetId,State:State}" --output table

--------------------------------------------------------------------
|                        DescribeNatGateways                       |
+------------------------+------------+----------------------------+
|           ID           |   State    |          Subnet            |
+------------------------+------------+----------------------------+
|  nat-0fb7a9f91ea939eb0 |  available |  subnet-0fb634552b7821b86  |
+------------------------+------------+----------------------------+


4️⃣ Add Route to NAT Gateway
aws ec2 create-route \
  --route-table-id <PRIVATE-RT-ID> \
  --destination-cidr-block 0.0.0.0/0 \
  --nat-gateway-id <NAT-GW-ID>

  This says:
“For any traffic going to the internet (0.0.0.0/0), send it to the NAT Gateway.”

Essentially, your private EC2s will say:
‘I want to reach the internet → go to NAT’


5️⃣ Associate Private Subnets with Private Route Table
aws ec2 associate-route-table \
  --route-table-id <PRIVATE-RT-ID> \
  --subnet-id <PRIVATE-SUBNET-1-ID>


(repeated for both subnets)

This step connects your private subnets to the route table you just created.

Now, any EC2 inside those subnets knows to send outbound traffic → NAT Gateway.