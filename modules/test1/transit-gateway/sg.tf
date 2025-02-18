# Security Group for Primary Region EC2
resource "aws_security_group" "primary_sg" {
  name        = "primary-sg"
  vpc_id      = aws_vpc.primary_vpc.id
  description = "Allow ICMP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.2.0.0/16"] # Allow ICMP from Secondary Region's CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Primary-SG"
  }
}

# Security Group for Secondary Region EC2
resource "aws_security_group" "secondary_sg" {
  provider    = aws.secondary
  name        = "secondary-sg"
  vpc_id      = aws_vpc.secondary_vpc.id
  description = "Allow ICMP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.0.0/16"] # Allow ICMP from Primary Region's CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Secondary-SG"
  }
}