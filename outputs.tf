output "ARN" {
  value = aws_eks_cluster.eks_cluster.arn
}

output "CertificateAuthorityData" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "ClusterSecurityGroupId" {
  # The control plane cluster security group is represented by the control_plane security group created above
  value = aws_security_group.control_plane.id
}

output "ClusterStackName" {
  value = var.eks_stack_name
}

output "Endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "FeatureNATMode" {
  value = "Single"
}

output "SecurityGroup" {
  value = aws_security_group.control_plane.id
}

output "ServiceRoleARN" {
  value = aws_iam_role.service_role.arn
}

output "SharedNodeSecurityGroup" {
  value = aws_security_group.cluster_shared_node.id
}

output "SubnetsPrivate" {
  value = join(",", [aws_subnet.private_c.id, aws_subnet.private_d.id, aws_subnet.private_a.id])
}

output "SubnetsPublic" {
  value = join(",", [aws_subnet.public_d.id, aws_subnet.public_a.id, aws_subnet.public_c.id])
}

output "VPC" {
  value = aws_vpc.eks_vpc.id
}

output "NodeGroupName" {
  description = "Name of the managed EKS node group"
  value       = aws_eks_node_group.managed_nodes.node_group_name
}

output "NodeGroupARN" {
  description = "ARN of the managed EKS node group"
  value       = aws_eks_node_group.managed_nodes.arn
}

output "NodeGroupStatus" {
  description = "Current status of the managed node group"
  value       = aws_eks_node_group.managed_nodes.status
}

output "NodeRoleARN" {
  description = "IAM role ARN used by the node group"
  value       = aws_iam_role.node_role.arn
}

output "NodeRoleName" {
  description = "IAM role name used by the node group"
  value       = aws_iam_role.node_role.name
}

output "NodeInstanceType" {
  description = "Instance type used by the node group"
  value       = var.node_instance_type
}

output "OIDCProviderARN" {
  description = "ARN of the IAM OIDC provider created for the cluster (IRSA)"
  value       = aws_iam_openid_connect_provider.eks.arn
}
