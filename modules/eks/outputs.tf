output "cluster_region" {
  value = var.aws_region
}

output "cluster_name" {
  value = var.eks_name
}

output "cluster_tags" {
  value = var.tags
}

output "public_subnet_ids" {
  value = var.public_subnet_ids
}

output "private_subnet_ids" {
  value = var.private_subnet_ids
}

output "vpc_id" {
  value       = aws_vpc.tcc_vpc.id
  description = "VPC id."
  sensitive   = false
}