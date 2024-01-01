provider "aws" {
  region = "ap-south-1"
  access_key = "add_your_access_key"
  secret_key = "add_your_secret_key"
  
}

#Created a VPC
resource "aws_vpc" "wp_vpc2" {
  cidr_block = "10.0.0.0/18"
  tags = {
    name= "word_press_vpc"
  }
}

# created a public subnet
resource "aws_subnet" "wp_pub" {
depends_on = [ aws_vpc.wp_vpc2 ]
  vpc_id = aws_vpc.wp_vpc2.id
  cidr_block = "10.0.0.0/19"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
    tags = {
      name = "wp_pub_subnet"
    }
}

# created a private subneet
resource "aws_subnet" "wp_priv" {
depends_on = [ aws_vpc.wp_vpc2 ]
  vpc_id = aws_vpc.wp_vpc2.id
    availability_zone = "ap-south-1b"
  cidr_block = "10.0.32.0/20"
    tags = {
      name = "wp_pub_subnet"
    }
}

# created a private subneet
resource "aws_subnet" "wp_priv1" {
depends_on = [ aws_vpc.wp_vpc2 ]
  vpc_id = aws_vpc.wp_vpc2.id
    availability_zone = "ap-south-1a"
  cidr_block = "10.0.48.0/20"
    tags = {
      name = "wp_priv_subnet1"
    }
}

#Internet gateway associated
resource "aws_internet_gateway" "wp_igw" {
  depends_on = [ aws_vpc.wp_vpc2 ]
  vpc_id = aws_vpc.wp_vpc2.id
  tags = {
    name = "wp_igw_16"
  }
}

# Route table creation
resource "aws_route_table" "wp_rt" {
  depends_on = [aws_internet_gateway.wp_igw]
  vpc_id = aws_vpc.wp_vpc2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wp_igw.id
  }
  tags = {
    name="wp_route"
  }
}

# Route table association
resource "aws_route_table_association" "wp_rta" {
    depends_on = [ aws_subnet.wp_pub,aws_route_table.wp_rt ]
    subnet_id = aws_subnet.wp_pub.id
    route_table_id = aws_route_table.wp_rt.id
}


# Route table creation private
resource "aws_route_table" "rds_rt" {
  depends_on = [aws_internet_gateway.wp_igw]
  vpc_id = aws_vpc.wp_vpc2.id

  tags = {
    name="rds_route"
  }
}

# Route table association private
resource "aws_route_table_association" "rds_rta" {
    depends_on = [ aws_subnet.wp_pub,aws_route_table.wp_rt ]
    subnet_id = aws_subnet.wp_priv.id
    route_table_id = aws_route_table.rds_rt.id
}

# Route table association private
resource "aws_route_table_association" "rds_rta1" {
    depends_on = [ aws_subnet.wp_pub,aws_route_table.wp_rt ]
    subnet_id = aws_subnet.wp_priv1.id
    route_table_id = aws_route_table.rds_rt.id
}



#wordpress Security group
resource "aws_security_group" "wp_sg" {
  name = "wordpress-sg"
  description = "Connection b/w Wordpress & client"
  vpc_id = aws_vpc.wp_vpc2.id

  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "httpd"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "mysql"
    from_port = 3306
    to_port = 3306
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security group for RDS MariaDB instance"
  vpc_id = aws_vpc.wp_vpc2.id

  # Allow MySQL/MariaDB traffic from the WordPress EC2 instance
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wp_sg.id]
  }

  # Additional rules for RDS security group if needed
  # E.g., to allow access from specific IP addresses
}

# Create RDS DB subnet group for the private subnet
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.wp_priv.id, aws_subnet.wp_pub.id]
}


# Create RDS MariaDB instance in the private subnet
resource "aws_db_instance" "mariadb" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mariadb"
  engine_version       = "10.6.14"
  instance_class       = "db.t3.micro"
  db_name                 = "wordpressdb"
  username             = "manishadmin"
  password             = "manishpasswd" # Replace with your desired password
  skip_final_snapshot  = true
  publicly_accessible  = false
  multi_az              = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.rds_subnet_group.name # Replace with your DB subnet group name
}

#Launch a WordPress host
resource "aws_instance" "WordPress" {
  ami = "add_your-ubuntu_AMI"
  instance_type = "t2.micro"
  key_name = "new-id"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.wp_sg.id]
  subnet_id = aws_subnet.wp_pub.id

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update && sudo apt upgrade -y
                sudo apt install -y apache2 php php-mysql mysql-client

                sudo systemctl start apache2
                sudo systemctl enable apache2

                sudo wget https://wordpress.org/latest.tar.gz
                sudo tar -xzf latest.tar.gz -C /var/www/html
                sudo mv /var/www/html/wordpress/* /var/www/html/
                sudo chown -R www-data:www-data /var/www/html/

                sudo systemctl restart apache2

                sudo sed -i "s/define('DB_NAME', '.*');/define('DB_NAME', 'wordpressdb');/" /var/www/html/wp-config.php
                sudo sed -i "s/define('DB_USER', '.*');/define('DB_USER', 'manishadmin');/" /var/www/html/wp-config.php
                sudo sed -i "s/define('DB_PASSWORD', '.*');/define('DB_PASSWORD', 'manishpasswd');/" /var/www/html/wp-config.php
                sudo sed -i "s/define('DB_HOST', '.*');/define('DB_HOST', '${aws_db_instance.mariadb.endpoint}');/" /var/www/html/wp-config.php
              EOF
  # Other resource settings...

  tags = {
    name = "wp_instance_30"
  }

}


output "wordpress_instances" {
  value = aws_instance.WordPress.public_ip
}

output "wordpress_endpoint" {
  value = aws_db_instance.mariadb.endpoint
}
