# variables.tf

# ================================
# 変数定義
# ================================

variable "project" {
  description = "プロジェクト名"
  type        = string
  default     = "dp"
}

variable "environment" {
  description = "環境名（dev/prod）"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "bucket_suffix" {
  description = "S3バケット名のサフィックス（日付など）"
  type        = string
  default     = "20250115"
}

variable "alert_email" {
  description = "アラート通知先メールアドレス"
  type        = string
}
