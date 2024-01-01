# WordPress Deployment on AWS using Terraform

![Architecture Snapshot](https://s3.ap-northeast-1.amazonaws.com/motulaal.io/wordpress/end+product.png)
## Objective
This project aims to deploy a scalable and secure WordPress environment on Amazon Web Services (AWS) using Terraform. It sets up a Virtual Private Cloud (VPC) with public and private subnets, an EC2 instance hosting WordPress in the public subnet, and an RDS MariaDB database in the private subnet. The objective is to automate the infrastructure provisioning and configuration process for WordPress hosting on AWS.

## Prerequisites
Before running the Terraform code, ensure you have:
- An AWS account
- Terraform installed locally
- AWS CLI configured with necessary permissions
- Basic understanding of AWS services and Terraform

## AWS Components Used

### VPC (Virtual Private Cloud)
![VPC](https://s3.ap-northeast-1.amazonaws.com/motulaal.io/wordpress/vpc.png)
- Creates an isolated network environment for resources
- `aws_vpc`: Defines the VPC and sets its CIDR block

### Subnets
![Subnets](https://s3.ap-northeast-1.amazonaws.com/motulaal.io/wordpress/public+subnet.png)
![Subnets](https://s3.ap-northeast-1.amazonaws.com/motulaal.io/wordpress/private+subnet.png)
- Divide the VPC into distinct segments
- `aws_subnet`: Creates public and private subnets with different CIDR blocks and availability zones

### Internet Gateway
![Igw](https://s3.ap-northeast-1.amazonaws.com/motulaal.io/wordpress/internet.png)
- Enables communication between the VPC and the internet
- `aws_internet_gateway`: Associates an internet gateway with the VPC

### Route Tables
![Route tables](https://s3.ap-northeast-1.amazonaws.com/motulaal.io/wordpress/routte+table.png)
- Manages traffic routing within the VPC
- `aws_route_table` and `aws_route_table_association`: Configures routing rules for public and private subnets

### Route Table Association
![Route Table Association](https://s3.ap-northeast-1.amazonaws.com/motulaal.io/wordpress/rta.png)
- `aws_route_table_association`: Associates route tables with subnets to control traffic flow between them.


### Security Groups
![Security groups](https://s3.ap-northeast-1.amazonaws.com/motulaal.io/wordpress/sg.png)
- Acts as a virtual firewall to control inbound and outbound traffic
- `aws_security_group`: Defines rules for allowing traffic to WordPress and RDS instances

### RDS (Relational Database Service)
![RDS](https://s3.ap-northeast-1.amazonaws.com/motulaal.io/wordpress/rds.png)
- Managed database service for MariaDB
- `aws_db_instance`: Creates a MariaDB instance for WordPress data storage
- `aws_db_subnet_group`: Groups subnets for RDS instance placement

### EC2 Instance
![EC2](https://s3.ap-northeast-1.amazonaws.com/motulaal.io/wordpress/ec2.png)
- Hosts WordPress application
- `aws_instance`: Deploys an EC2 instance and configures it to install and run WordPress

## Terraform Modules Explained

### VPC, Subnets, and Internet Gateway
- Defines the VPC structure, subnets, and connectivity to the internet

### Route Tables and Associations
- Manages routing rules for public and private subnets

### Security Groups
- Controls traffic for WordPress EC2 instance and RDS MariaDB instance

### RDS Database
- Sets up the MariaDB database instance and subnet group for WordPress data storage

### EC2 Instance Configuration
- Launches an EC2 instance and configures it with necessary software for hosting WordPress

## Steps to Run Terraform

1. Clone this repository.
2. Ensure AWS credentials are configured properly.
3. Open a terminal and navigate to the project directory.
4. Run `terraform init` to initialize Terraform.
5. Run `terraform plan` to review the execution plan.
6. Run `terraform apply` and confirm by typing `yes` to deploy the infrastructure.

## Conclusion
This Terraform script automates the setup of a WordPress environment on AWS, maintaining a secure architecture with public and private subnets, ensuring WordPress hosting in a scalable and isolated manner.

Feel free to modify the code or parameters according to your specific requirements.
