# NACL for Primary VPC
resource "aws_network_acl" "primary_nacl" {
  vpc_id = aws_vpc.primary_vpc.id

  ingress {
    protocol   = "icmp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    protocol   = "icmp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "Primary-NACL"
  }
}

# NACL for Secondary VPC
resource "aws_network_acl" "secondary_nacl" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id

  ingress {
    protocol   = "icmp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    protocol   = "icmp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "Secondary-NACL"
  }
}

# Associate Primary NACL with Primary Subnets
resource "aws_network_acl_association" "primary_nacl_association" {
  count          = length(aws_subnet.primary_subnets)
  subnet_id      = aws_subnet.primary_subnets[count.index].id
  network_acl_id = aws_network_acl.primary_nacl.id
}

# Associate Secondary NACL with Secondary Subnets
resource "aws_network_acl_association" "secondary_nacl_association" {
  provider       = aws.secondary
  count          = length(aws_subnet.secondary_subnets)
  subnet_id      = aws_subnet.secondary_subnets[count.index].id
  network_acl_id = aws_network_acl.secondary_nacl.id
}
