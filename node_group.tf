resource "aws_iam_role" "node_role" {
  name = "${var.prefix}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })

  tags = { Name = "${var.prefix}-node-role" }
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Optional: SSM policy so nodes can be managed via Session Manager (helpful)
resource "aws_iam_role_policy_attachment" "node_AmazonSSMManagedInstanceCore" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_eks_node_group" "managed_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name != "" ? var.node_group_name : "${var.prefix}-managed-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
    aws_subnet.private_d.id,
  ]

  scaling_config {
    desired_size = var.node_group_desired_capacity
    min_size     = var.node_group_min_size
    max_size     = var.node_group_max_size
  }

  instance_types = [var.node_instance_type]
  capacity_type  = var.node_capacity_type

  tags = {
    Name = "${var.prefix}-managed-node"
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}
