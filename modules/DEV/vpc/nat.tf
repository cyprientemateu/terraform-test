resource "aws_nat_gateway" "tcc_nat" {
  count = length(var.private_subnet_cidrs)
  # count         = var.tags["environment"] == "development" ? length(var.availability_zones) : var.nat_number
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  allocation_id = element(aws_eip.tcc_eip[*].id, count.index)

  tags = {
    Name = "${var.vpc_name}-tcc_nat-gateway-${count.index + 1}"
  }
  depends_on = [aws_internet_gateway.tcc_igw]
}