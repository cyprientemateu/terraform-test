# Outputs
output "vpc_id" {
  value = aws_vpc.tcc_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "eip_ids" {
  value = aws_eip.tcc_eip[*].id
}

output "eip_tags" {
  value = aws_eip.tcc_eip[*].tags
}

output "nat_ids" {
  value = aws_nat_gateway.tcc_nat[*].id
}

output "nat_tags" {
  value = aws_nat_gateway.tcc_nat[*].tags
}

output "route_table_public_ids" {
  value = aws_route_table.public.id
}

output "route_table_private_ids" {
  value = aws_route_table.private[*].id
}

output "private_associate_route_table_ids" {
  value = aws_route_table_association.private[*].id
}

output "public_associate_route_table_ids" {
  value = aws_route_table_association.public[*].id
}