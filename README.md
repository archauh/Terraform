# Terraform AWS Web Server Infrastructure

📌 Prerequisites
Terraform v1.x
AWS CLI configured (aws configure)
IAM user with EC2, VPC, and S3 permissions

This project provisions a basic **web server infrastructure on AWS** using Terraform. It includes:

- VPC with public subnets
- Internet Gateway and Route Tables
- EC2 Instances with user data
- Application Load Balancer (ALB)
- Target Groups and Listeners
- Security Group for HTTP and SSH
- An S3 Bucket

## 📁 Project Structure

Terraform/
├── main.tf # Main infrastructure resources
├── provider.tf # AWS provider configuration
├── variables.tf # Input variable definitions
├── userdata.sh # Bootstrap script for EC2 instances
└── README.md # Project documentation


## 🚀 Resources Created

- `aws_vpc`: Custom VPC
- `aws_subnet`: Two public subnets in different AZs
- `aws_internet_gateway`: Enables public internet access
- `aws_route_table` + `association`: For routing internet traffic
- `aws_security_group`: Allows HTTP (80) and SSH (22)
- `aws_instance`: Two EC2 web servers with bootstrap script
- `aws_s3_bucket`: Simple S3 bucket
- `aws_lb`: Application Load Balancer (ALB)
- `aws_lb_target_group`: For load balancer to route traffic
- `aws_lb_listener`: Listens on HTTP and forwards to target group

## 🛠️ Usage

1. **Initialize Terraform:**

   ```bash
   terraform init
# Validate the configuration:

teraform validate

# Apply the configuration:
terraform apply

🔐 Security Notes
SSH is open to the world (0.0.0.0/0). Consider restricting it to your IP in production.
No backend state configuration is included. Use remote state (e.g., S3 + DynamoDB) for team environments.

🧹 Clean Up
To destroy all resources:

terraform destroy
