# glue.tf

# ================================
# Glue Data Catalog
# ================================

# Glue Database
# Athenaからクエリするためのメタデータを格納
resource "aws_glue_catalog_database" "main" {
  name        = "${var.project}_db"
  description = "Data Pipeline用データベース"
}

# Glue Crawler
# S3のParquetファイルをクロールしてスキーマを自動検出
resource "aws_glue_crawler" "main" {
  name          = "${var.project}-crawler"
  database_name = aws_glue_catalog_database.main.name
  role          = aws_iam_role.glue_crawler.arn

  # クロール対象のS3パス
  s3_target {
    path = "s3://${aws_s3_bucket.processed.id}/processed/"
  }

  # スキーマ変更時の動作
  schema_change_policy {
    delete_behavior = "LOG"              # 削除はログのみ
    update_behavior = "UPDATE_IN_DATABASE" # 更新は反映
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-crawler"
  })
}
