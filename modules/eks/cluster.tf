data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "tcc_eks_cluster_role" {
  name               = format("tcc_eks_cluster_role-%s-%s", var.tags["id"], var.tags["project"])
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "tcc-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.tcc_eks_cluster_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "tcc-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.tcc_eks_cluster_role.name
}

resource "aws_eks_cluster" "tcc_eks_cluster" {
  name     = format("tcc_eks_cluster-%s-%s", var.tags["id"], var.tags["project"])
  role_arn = aws_iam_role.tcc_eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access

    # subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)
    subnet_ids = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id,
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.tcc-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.tcc-AmazonEKSVPCResourceController
  ]
}