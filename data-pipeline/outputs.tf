# ================================
# 出力値
# ================================

# S3バケット名
output "s3_raw_bucket" {
  description = "生データ用S3バケット名"
  value       = aws_s3_bucket.raw.bucket
}

output "s3_processed_bucket" {
  description = "加工済みデータ用S3バケット名"
  value       = aws_s3_bucket.processed.bucket
}

# Lambda関数
output "lambda_function_name" {
  description = "Lambda関数名"
  value       = aws_lambda_function.etl.function_name
}

# Glue
output "glue_database_name" {
  description = "Glueデータベース名"
  value       = aws_glue_catalog_database.analytics.name
}

output "glue_crawler_name" {
  description = "Glue Crawler名"
  value       = aws_glue_crawler.processed.name
}

# Step Functions
output "stepfunctions_arn" {
  description = "Step FunctionsステートマシンのARN"
  value       = aws_sfn_state_machine.pipeline.arn
}

output "stepfunctions_name" {
  description = "Step Functionsステートマシン名"
  value       = aws_sfn_state_machine.pipeline.name
}
