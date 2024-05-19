resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.tcc_eks_cluster.name
  node_group_name = format("tcc_node_group-%s-%s", var.tags["id"], var.tags["project"])
  node_role_arn   = aws_iam_role.tcc_node_role.arn
  subnet_ids      = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  #   subnet_ids      = var.private_subnet_ids
  #   ["aws_subnet.public_1", "aws_subnet.public_2"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "tcc_node_role" {
  name               = format("tcc_node_role-%s-%s", var.tags["id"], var.tags["project"])
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com",
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.tcc_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.tcc_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.tcc_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
