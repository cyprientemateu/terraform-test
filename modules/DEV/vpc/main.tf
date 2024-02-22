terraform {
  required_version = "~> 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_internet_gateway" "tcc_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_vpc" "tcc_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
  # depends_on = [aws_internet_gateway.igw] # Ensure the VPC is created after the Internet Gateway
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.tcc_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.tcc_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "tcc_nat" {
  count         = length(var.private_subnet_cidrs)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  allocation_id = element(aws_eip.tcc_eip[*].id, count.index)

  tags = {
    Name = "${var.vpc_name}-tcc_nat-gateway-${count.index + 1}"
  }
}

resource "aws_eip" "tcc_eip" {
  count = length(var.private_subnet_cidrs)

  tags = {
    Name = "${var.vpc_name}-tcc_eip-${count.index + 1}"
  }
}

# Outputs
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  value = aws_eip.nat[*].id
}

output "nat_ids" {
  value = aws_nat_gateway.nat[*].id
}

output "nat_tags" {
  value = aws_nat_gateway.nat[*].tags
}
