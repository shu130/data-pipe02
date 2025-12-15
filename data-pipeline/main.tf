# ================================
# Terraformバージョン・プロバイダ設定
# ================================

terraform {
  # Terraformのバージョン指定（1.0.0以上）
  required_version = ">= 1.0.0"

  # 使用するプロバイダを指定
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWSプロバイダの取得元
      version = "~> 5.0"         # 5.x系を使用
    }
  }
}

# AWSプロバイダの設定
provider "aws" {
  region = "ap-northeast-1"  # 東京リージョン
}
