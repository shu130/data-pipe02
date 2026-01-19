# tf/backend.tf

# Terraformの状態管理をS3で行う設定
# これにより、チームでの共有やCI/CDが可能になる
terraform {
  backend "s3" {
    bucket  = "dp-tfstate-bucket"           # 保存先バケット
    key     = "pipeline/terraform.tfstate"  # 保存ファイルのパス
    region  = "ap-northeast-1"              # リージョン
    encrypt = true                          # 暗号化を有効化
  }
}