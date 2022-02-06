output "eks_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cert_auth_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}

output "eks_token" {
  value     = data.aws_eks_cluster_auth.eks_cluster.token
  sensitive = true
}

output "eks_oidc_url" {
  value = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}
