variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "sample-nodejs"
}

variable "github_repo" {
  description = "GitHub repo in owner/name format (for OIDC trust)"
  type        = string
  default     = "OrenOren1/refael"
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "refael"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_desired_nodes" {
  description = "Desired EKS node count"
  type        = number
  default     = 2
}
