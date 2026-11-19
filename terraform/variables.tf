variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ecr_repo_name" {
  type    = string
  default = "sample-nodejs"
}

variable "github_repo" {
  type        = string
  description = "GitHub owner/repo used in OIDC subject claim"
  default     = "OrenOren1/refael"
}

variable "domain_name" {
  type        = string
  description = "Domain for Ingress TLS cert (e.g. app.example.com)"
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for domain_name"
}
