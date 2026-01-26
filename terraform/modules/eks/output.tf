output "cluster_name" {
  value = aws_eks_cluster.main.name 
  
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.main.certificate_authority
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn 
}

output "oidc_role" {
  description = "CICD GitHub role."
  value       = aws_iam_role.github_actions.arn
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

