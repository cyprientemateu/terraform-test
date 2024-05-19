resource "aws_eks_node_group" "tcc_node_group_private" {
  cluster_name    = aws_eks_cluster.tcc_eks_cluster.name
  node_group_name = format("tcc-node-group-%s-%s", var.tags["id"], var.tags["project"])
  node_role_arn   = aws_iam_role.tcc_node_role.arn
  subnet_ids = [
    data.aws_subnet.private-01.id,
    data.aws_subnet.private-02.id,
    data.aws_subnet.private-03.id
  ]

  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key = "terraform"
  }

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
    # max_unavailable_percentage = 50
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = merge(var.tags, {
    Name                                            = format("%s-%s-%s-green-node-group", var.tags["id"], var.tags["environment"], var.tags["project"])
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "${var.shared_owned}"
    "k8s.io/cluster-autoscaler/enabled"             = "${var.enable_cluster_autoscaler}"
    },
  )
}

# resource "aws_eks_node_group" "tcc_node_group_public" {
#   cluster_name    = aws_eks_cluster.tcc_eks_cluster.name
#   node_group_name = "tcc-node-group-public"
#   node_role_arn   = aws_iam_role.tcc_node_role.arn
#   subnet_ids      = [aws_subnet.public_1.id, aws_subnet.public_2.id]
#   #   subnet_ids      = var.private_subnet_ids
#   #   ["aws_subnet.public_1", "aws_subnet.public_2"]

#   ami_type       = "AL2_x86_64"
#   capacity_type  = "ON_DEMAND"
#   disk_size      = 20
#   instance_types = ["t3.medium"]

#   # ami_type       = var(config.ami_type)
#   # capacity_type  = var(config.capacity_type)
#   # disk_size      = var(config.disk_size)
#   # instance_types = var(config.instance_types)

#   remote_access {
#     ec2_ssh_key = "terraform"
#   }

#   scaling_config {
#     desired_size = 1
#     max_size     = 2
#     min_size     = 1
#   }

#   update_config {
#     max_unavailable = 1
#     # max_unavailable_percentage = 50
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
#   ]

#   tags = {
#     Name = "Public-Node-Group"
#   }
# }

# resource "aws_iam_role" "tcc_node_role" {
#   name               = "tcc-node-role"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com",
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

resource "aws_iam_role" "tcc_node_role" {
  name = "tcc-node-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          # "Service" : ["eks.amazonaws.com", "ec2.amazonaws.com"] # Update the service principal to eks.amazonaws.com
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
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

# resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   role       = aws_iam_role.worker.name
# }