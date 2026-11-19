output "ecr_repository_url" {
  description = "Set as ECR_REGISTRY in CI or reference from values.yaml"
  value       = aws_ecr_repository.app.repository_url
}

output "github_actions_role_arn" {
  description = "Set as AWS_ROLE_TO_ASSUME secret in GitHub repository settings"
  value       = aws_iam_role.github_actions.arn
}

output "acm_certificate_arn" {
  description = "Reference in Helm values or Ingress annotation"
  value       = aws_acm_certificate.ingress.arn
}
