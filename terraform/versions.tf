terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  # profile is optional — set via var.aws_profile, AWS_PROFILE env var,
  # or leave empty to use the standard credential chain (env keys, IAM role, etc.)
  profile = var.aws_profile != "" ? var.aws_profile : null
}
