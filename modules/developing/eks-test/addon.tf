# resource "aws_eks_addon" "example" {
#   cluster_name = aws_eks_cluster.tcc_eks_cluster.name
#   addon_name   = "vpc-cni"
# }