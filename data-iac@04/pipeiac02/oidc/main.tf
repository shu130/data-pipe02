# oidc/main.tf

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
  }
}

provider "aws" {
  region = var.aws_region
}

# ================================
# OIDCプロバイダ
# ================================

# GitHubをAWSが信頼するための設定
# これにより、GitHub ActionsがAWSリソースを操作できる
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name        = "github-actions-oidc"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ================================
# IAMロール
# ================================

# GitHub Actionsが引き受けるロール
resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform"

  # 信頼ポリシー：どのGitHubリポジトリからのアクセスを許可するか
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # このリポジトリからのみ許可
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_username}/${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "github-actions-terraform"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ================================
# 権限ポリシー
# ================================

# 学習用：AdministratorAccess（本番では最小権限に）
resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
