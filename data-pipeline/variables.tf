# ================================
# 変数定義
# ================================

# 環境名（dev / stg / prod など）
variable "environment" {
  description = "環境名"
  type        = string
  default     = "dev"
}

# プロジェクト名
variable "project" {
  description = "プロジェクト名"
  type        = string
  default     = "data-pipeline"
}

# S3バケット名のサフィックス（一意にするため）
variable "bucket_suffix" {
  description = "S3バケット名のサフィックス"
  type        = string
  default     = "20251214"
}

# ================================
# 共通タグ（ローカル変数）
# ================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
