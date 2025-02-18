# EC2 Instance in Primary Region (us-east-1)
resource "aws_instance" "primary_instance" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.primary_subnets[0].id
  key_name                    = "terraform"
  security_groups             = [aws_security_group.primary_sg.id]
  associate_public_ip_address = true # Enables public IP

  tags = {
    Name = "Primary-Region-EC2"
  }
}

# EC2 Instance in Secondary Region (us-west-2)
resource "aws_instance" "secondary_instance" {
  provider                    = aws.secondary
  ami                         = "ami-00c257e12d6828491"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.secondary_subnets[0].id
  key_name                    = "terraform1"
  security_groups             = [aws_security_group.secondary_sg.id]
  associate_public_ip_address = true # Enables public IP

  tags = {
    Name = "Secondary-Region-EC2"
  }
}