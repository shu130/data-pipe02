# ================================
# S3バケット
# ================================

# 生データ用バケット（JSON形式の注文ログを置く）
resource "aws_s3_bucket" "raw" {
  bucket = "${var.project}-raw-${var.bucket_suffix}"

  # 学習用：削除時に中身ごと消せるようにする
  force_destroy = true

  tags = merge(local.common_tags, {
    Name = "${var.project}-raw"
  })
}

# 加工済みデータ用バケット（CSV形式に変換後のデータを置く）
resource "aws_s3_bucket" "processed" {
  bucket = "${var.project}-processed-${var.bucket_suffix}"

  # 学習用：削除時に中身ごと消せるようにする
  force_destroy = true

  tags = merge(local.common_tags, {
    Name = "${var.project}-processed"
  })
}
