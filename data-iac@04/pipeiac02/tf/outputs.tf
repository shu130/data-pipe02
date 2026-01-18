# outputs.tf

# ================================
# 出力値
# ================================

# S3バケット
output "raw_bucket_id" {
  description = "Rawバケット名"
  value       = aws_s3_bucket.raw.id
}

output "raw_bucket_arn" {
  description = "RawバケットARN"
  value       = aws_s3_bucket.raw.arn
}

output "processed_bucket_id" {
  description = "Processedバケット名"
  value       = aws_s3_bucket.processed.id
}

output "processed_bucket_arn" {
  description = "ProcessedバケットARN"
  value       = aws_s3_bucket.processed.arn
}

# IAMロール
output "lambda_etl_role_arn" {
  description = "Lambda ETL用IAMロールARN"
  value       = aws_iam_role.lambda_etl.arn
}

output "glue_crawler_role_arn" {
  description = "Glue Crawler用IAMロールARN"
  value       = aws_iam_role.glue_crawler.arn
}

# Lambda
output "lambda_etl_arn" {
  description = "Lambda ETL関数ARN"
  value       = aws_lambda_function.etl.arn
}

output "lambda_etl_name" {
  description = "Lambda ETL関数名"
  value       = aws_lambda_function.etl.function_name
}

# Glue
output "glue_database_name" {
  description = "Glue Database名"
  value       = aws_glue_catalog_database.main.name
}

output "glue_crawler_name" {
  description = "Glue Crawler名"
  value       = aws_glue_crawler.main.name
}

# Step Functions
output "sfn_arn" {
  description = "Step Functions State Machine ARN"
  value       = aws_sfn_state_machine.pipeline.arn
}

output "sfn_name" {
  description = "Step Functions State Machine名"
  value       = aws_sfn_state_machine.pipeline.name
}

# SNS
output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic.alert.arn
}
