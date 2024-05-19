resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tcc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tcc_igw.id
  }

  tags = {
    # Name = "${var.vpc_name}-public-route-table"
    Name = format("%s-%s-%s-public-route-table", var.tags["id"], var.tags["environment"], var.tags["project"])
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.tcc_vpc.id
  count  = length(var.availability_zones)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.tcc_nat[*].id, count.index)
  }

  tags = {
    # Name = "${var.vpc_name}-private-route-table-${count.index}"
    Name = format("%s-%s-%s-private-route-table-${count.index + 1}-${element(var.availability_zones, count.index)}", var.tags["id"], var.tags["environment"], var.tags["project"])
  }
}

