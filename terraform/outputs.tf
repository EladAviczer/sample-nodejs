output "ecr_repository_url" {
  description = "Full ECR image URL prefix (use as image.repository in values.yaml)"
  value       = aws_ecr_repository.app.repository_url
}

output "github_actions_role_arn" {
  description = "Set as AWS_ROLE_TO_ASSUME GitHub secret"
  value       = aws_iam_role.github_actions.arn
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "configure_kubectl" {
  description = "Run this after apply to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.eks_cluster_name} --profile assignment-tests"
}
