# Create IAM OIDC provider for the EKS cluster (IRSA)
# This allows creating IAM roles for service accounts (pod-level permissions)

data "tls_certificate" "eks_oidc" {
  # The cluster's OIDC issuer URL (includes https://)
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]

  tags = {
    Name = "${var.prefix}-eks-oidc-provider"
  }
}
