# data "aws_iam_policy_document" "_pods_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["pods.eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }

# resource "aws_iam_role" "eks_pod_example" {
#   name               = "eks-pod-identity-example"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "example_s3" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
#   role       = aws_iam_role.example.name
# }

# resource "aws_eks_pod_identity_association" "example" {
#   cluster_name    = aws_eks_cluster.tcc_eks_cluster.name
#   namespace       = "tcc"
#   service_account = "example-sa"
#   role_arn        = aws_iam_role.example.arn
# }