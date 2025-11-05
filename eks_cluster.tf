# Security groups
resource "aws_security_group" "cluster_shared_node" {
  name        = "${var.prefix}-ClusterSharedNodeSecurityGroup"
  vpc_id      = aws_vpc.eks_vpc.id
  description = "Communication between all nodes in the cluster"
  tags        = { Name = "${var.prefix}-ClusterSharedNodeSecurityGroup" }
}

resource "aws_security_group" "control_plane" {
  name        = "${var.prefix}-ControlPlaneSecurityGroup"
  vpc_id      = aws_vpc.eks_vpc.id
  description = "Communication between the control plane and worker nodegroups"
  tags        = { Name = "${var.prefix}-ControlPlaneSecurityGroup" }
}

# Ingress rules
resource "aws_security_group_rule" "ingress_default_cluster_to_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.cluster_shared_node.id
  source_security_group_id = aws_security_group.control_plane.id
  description              = "Allow managed and unmanaged nodes to communicate with each other (all ports)"
  depends_on               = [aws_eks_cluster.eks_cluster]
}

resource "aws_security_group_rule" "ingress_inter_nodegroup" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.cluster_shared_node.id
  source_security_group_id = aws_security_group.cluster_shared_node.id
  description              = "Allow nodes to communicate with each other (all ports)"
}

resource "aws_security_group_rule" "ingress_node_to_default_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.cluster_shared_node.id
  description              = "Allow unmanaged nodes to communicate with control plane (all ports)"
  depends_on               = [aws_eks_cluster.eks_cluster]
}

# IAM role for EKS Control Plane
resource "aws_iam_role" "service_role" {
  name = "${var.prefix}-ServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "eks.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "service_role_attach_1" {
  role       = aws_iam_role.service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "service_role_attach_2" {
  role       = aws_iam_role.service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.service_role.arn
  version  = var.eks_version

  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [aws_security_group.control_plane.id]
    subnet_ids = [
      aws_subnet.public_d.id,
      aws_subnet.public_a.id,
      aws_subnet.public_c.id,
      aws_subnet.private_c.id,
      aws_subnet.private_d.id,
      aws_subnet.private_a.id,
    ]
  }

  tags = {
    Name = "${var.prefix}-ControlPlane"
  }
}
