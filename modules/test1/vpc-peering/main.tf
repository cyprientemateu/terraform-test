terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Primary region
}

provider "aws" {
  alias  = "secondary"
  region = "us-east-2" # Secondary region
}

# Create VPCs
resource "aws_vpc" "primary_vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "secondary_vpc" {
  provider   = aws.secondary
  cidr_block = "10.2.0.0/16"
}

# Create VPC Peering Connection
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id      = aws_vpc.primary_vpc.id
  peer_vpc_id = aws_vpc.secondary_vpc.id
  peer_region = "us-east-2"

  tags = {
    Name = "VPC-Peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "vpc_peering_accepter" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  auto_accept               = true

  tags = {
    Name = "VPC-Peering-Accepter"
  }
}

# Route Table Updates
resource "aws_route_table" "primary_route_table" {
  vpc_id = aws_vpc.primary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }

  route {
    cidr_block                = "10.2.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }
}

resource "aws_route_table" "secondary_route_table" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }

  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  }
}

# Associate Route Tables
resource "aws_route_table_association" "primary_rt_association" {
  subnet_id      = aws_subnet.primary_subnets[0].id
  route_table_id = aws_route_table.primary_route_table.id
}

resource "aws_route_table_association" "secondary_rt_association" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_subnets[0].id
  route_table_id = aws_route_table.secondary_route_table.id
}

# Subnets
resource "aws_subnet" "primary_subnets" {
  count             = 2
  vpc_id            = aws_vpc.primary_vpc.id
  cidr_block        = "10.1.${count.index}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
}

resource "aws_subnet" "secondary_subnets" {
  provider          = aws.secondary
  count             = 2
  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block        = "10.2.${count.index}.0/24"
  availability_zone = element(["us-east-2a", "us-east-2b"], count.index)
}

# EC2 Instances
# EC2 Instance in Primary Region (us-east-1)
resource "aws_instance" "primary_instance" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.primary_subnets[0].id
  key_name                    = aws_key_pair.generated_key_primary.key_name
  security_groups             = [aws_security_group.primary_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Primary-Region-EC2"
  }
}

# EC2 Instance in Secondary Region (us-east-2)
resource "aws_instance" "secondary_instance" {
  provider                    = aws.secondary
  ami                         = "ami-0cb91c7de36eed2cb"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.secondary_subnets[0].id
  key_name                    = aws_key_pair.generated_key_secondary.key_name
  security_groups             = [aws_security_group.secondary_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Secondary-Region-EC2"
  }
}
