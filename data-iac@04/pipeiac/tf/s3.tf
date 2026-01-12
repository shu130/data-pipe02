# s3.tf

# ================================
# S3バケット
# ================================

# Rawバケット（生データ用）
# JSONファイルをアップロードする入力バケット
resource "aws_s3_bucket" "raw" {
  bucket        = "${var.project}-raw-${var.bucket_suffix}"
  force_destroy = true # 学習用：中身ごと削除可能

  tags = merge(local.common_tags, {
    Name = "${var.project}-raw"
  })
}

# Processedバケット（加工済みデータ用）
# Parquetファイルを保存する出力バケット
resource "aws_s3_bucket" "processed" {
  bucket        = "${var.project}-processed-${var.bucket_suffix}"
  force_destroy = true # 学習用：中身ごと削除可能

  tags = merge(local.common_tags, {
    Name = "${var.project}-processed"
  })
}
