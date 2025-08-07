# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "terraform-ec2"
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root EBS volume"
  type        = string
  default     = "gp3"
}

variable "additional_volume_size" {
  description = "Size of additional EBS volume in GB (0 to disable)"
  type        = number
  default     = 0
}

variable "additional_volume_type" {
  description = "Type of additional EBS volume"
  type        = string
  default     = "gp3"
}

# Data source to get the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.instance_name}-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.instance_name}-igw"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.instance_name}-public-subnet"
  }
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.instance_name}-public-rt"
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create a security group
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.instance_name}-sg"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# Create EC2 instance
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name != "" ? var.key_name : null
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Root volume configuration
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${var.instance_name}-root-volume"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>Hello from Terraform EC2 Ubuntu!</h1>" > /var/www/html/index.html
              
              # If additional volume exists, format and mount it
              if [ -b /dev/nvme1n1 ]; then
                # Format the additional volume
                mkfs.ext4 /dev/nvme1n1
                
                # Create mount point
                mkdir -p /mnt/data
                
                # Mount the volume
                mount /dev/nvme1n1 /mnt/data
                
                # Add to fstab for persistent mounting
                echo '/dev/nvme1n1 /mnt/data ext4 defaults,nofail 0 2' >> /etc/fstab
                
                # Set permissions
                chmod 755 /mnt/data
                chown ubuntu:ubuntu /mnt/data
              fi
              EOF

  tags = {
    Name = var.instance_name
  }
}

# Create additional EBS volume (optional)
resource "aws_ebs_volume" "additional" {
  count             = var.additional_volume_size > 0 ? 1 : 0
  availability_zone = aws_instance.ec2.availability_zone
  size              = var.additional_volume_size
  type              = var.additional_volume_type
  encrypted         = true

  tags = {
    Name = "${var.instance_name}-additional-volume"
  }
}

# Attach additional volume to EC2 instance
resource "aws_volume_attachment" "additional" {
  count       = var.additional_volume_size > 0 ? 1 : 0
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.additional[0].id
  instance_id = aws_instance.ec2.id
}
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ec2.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.ec2.public_dns
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = var.key_name != "" ? "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.ec2.public_ip}" : "No key pair specified"
}

output "storage_info" {
  description = "Storage information"
  value = {
    root_volume_size       = var.root_volume_size
    root_volume_type       = var.root_volume_type
    additional_volume_size = var.additional_volume_size > 0 ? var.additional_volume_size : "None"
    additional_mount_point = var.additional_volume_size > 0 ? "/mnt/data" : "None"
  }
}