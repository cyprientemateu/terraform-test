# Create VPCs
resource "aws_vpc" "primary_vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "secondary_vpc" {
  provider   = aws.secondary
  cidr_block = "10.2.0.0/16"
}