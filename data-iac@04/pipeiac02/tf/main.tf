# main.tf

# ================================
# プロバイダ設定
# ================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

# AWSプロバイダ
provider "aws" {
  region = var.aws_region
}

# ================================
# 共通タグ
# ================================

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
# CI/CD test - GitHub Actions動作確認
