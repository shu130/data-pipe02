# ================================
# Glue Database
# ================================

# Athenaからクエリするためのデータベース（メニュー表のフォルダ）
resource "aws_glue_catalog_database" "analytics" {
  name = "${replace(var.project, "-", "_")}_db"
}

# ================================
# Glue Crawler
# ================================

# S3 processedをスキャンしてテーブル定義を作成
resource "aws_glue_crawler" "processed" {
  name          = "${var.project}-crawler"
  role          = aws_iam_role.glue_crawler.arn
  database_name = aws_glue_catalog_database.analytics.name

  # スキャン対象のS3パス
  s3_target {
    path = "s3://${aws_s3_bucket.processed.bucket}/"
  }

  # スキーマ変更時の挙動
  schema_change_policy {
    delete_behavior = "LOG"                  # 削除されたデータはログに記録
    update_behavior = "UPDATE_IN_DATABASE"   # 変更は自動更新
  }

  tags = local.common_tags
}
