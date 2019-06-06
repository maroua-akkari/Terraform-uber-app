# Terraform uber app

Terraform was used to automate the process of running an uber app on AWS.

The main.tf file contains instructions to make:
- 1 VPC
- 1 public and 1 private subnet
- 1 internet gateway
- 1 public and 1 private instance within the subnets
- Security groups for said instances 
- Key pair

To run this script, type in terminal:
`terraform apply`

In AWS: 
Connect the pubic instance

In terminal:
1. Change the permissions using chomd
2. SSH into the Ubuntu VM 

Connect to the instance made using its public DNS, in a web browser go to:

ec2-34-242-186-67.eu-west-1.compute.amazonaws.com



