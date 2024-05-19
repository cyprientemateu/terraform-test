# resource "aws_eks_access_entry" "example" {
#   cluster_name      = aws_eks_cluster.example.name
#   principal_arn     = aws_iam_role.example.arn
#   kubernetes_groups = ["group-1", "group-2"]
#   type              = "STANDARD"
# }


provider "kubernetes" {
  host                   = data.aws_eks_cluster.tcc_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.tcc_eks-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.example.token
}