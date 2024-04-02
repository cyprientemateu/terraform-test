resource "aws_internet_gateway" "tcc_igw" {
  vpc_id = aws_vpc.tcc_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}
