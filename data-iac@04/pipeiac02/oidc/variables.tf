# oidc/variables.tf

# ================================
# 必須変数
# ================================

variable "github_username" {
  description = "GitHubユーザー名またはOrganization名"
  type        = string
}

variable "github_repo" {
  description = "GitHubリポジトリ名"
  type        = string
}

# ================================
# オプション変数（デフォルト値あり）
# ================================

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "プロジェクト名（タグ用）"
  type        = string
  default     = "dp"
}

variable "environment" {
  description = "環境名（タグ用）"
  type        = string
  default     = "dev"
}
