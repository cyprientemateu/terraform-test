output "cluster_region" {
  value = var.aws_region
}

output "cluster_name" {
  value = var.cluster_name
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
output "endpoint" {
  value = aws_eks_cluster.tcc_eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.tcc_eks_cluster.certificate_authority[0].data
}