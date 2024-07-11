# resource "aws_eks_identity_provider_config" "example" {
#   cluster_name = aws_eks_cluster.tcc_eks_cluster.name

#   oidc {
#     client_id                     = "your client_id"
#     identity_provider_config_name = "example"
#     issuer_url                    = "your issuer_url"
#   }
# }

# or

# data "tls_certificate" "cluster_connect-url" {
#   url = aws_eks_cluster.a1angel-cluster.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "oidc_provider" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.cluster_connect-url.certificates[0].sha1_fingerprint]
#   url             = data.tls_certificate.cluster_connect-url.url
# }
