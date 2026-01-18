# tf/backend.tf
#
# S3バックエンド設定（オプション）
#
# 【有効化手順】
# 1. 下記コマンドでS3バケットを作成:
#    aws s3 mb s3://dp-tfstate-bucket --region ap-northeast-1
#
# 2. このファイルのコメントを解除
#
# 3. terraform init -migrate-state を実行
#
# ============================================

# terraform {
#   backend "s3" {
#     bucket         = "dp-tfstate-bucket"
#     key            = "pipeline/terraform.tfstate"
#     region         = "ap-northeast-1"
#     encrypt        = true
#   }
# }
