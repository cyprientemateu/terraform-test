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
  name               = format("tcc-eks-cluster-role-%s-%s", var.tags["id"], var.tags["project"])
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
  name     = format("tcc-eks-cluster-%s-%s", var.tags["id"], var.tags["project"])
  role_arn = aws_iam_role.tcc_eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access_cidrs

    subnet_ids = [
      data.aws_subnet.public-01.id,
      data.aws_subnet.public-02.id,
      data.aws_subnet.public-03.id
    ]
  }


  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.tcc-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.tcc-AmazonEKSVPCResourceController
  ]
}