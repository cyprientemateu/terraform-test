# Route Table Updates
resource "aws_route_table" "primary_route_table" {
  vpc_id = aws_vpc.primary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }

  route {
    cidr_block         = "10.2.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.primary_tgw.id
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
    cidr_block         = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.secondary_tgw.id
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