# lambda.tf

# ================================
# Lambda関数
# ================================

# Lambda関数のソースコードをZIPに圧縮
data "archive_file" "lambda_etl" {
  type        = "zip"
  source_file = "${path.module}/lambda/etl.py"
  output_path = "${path.module}/lambda/etl.zip"
}

# Lambda関数（ETL処理）
# JSON→Parquet変換を行うメイン処理
resource "aws_lambda_function" "etl" {
  function_name = "${var.project}-etl"
  role          = aws_iam_role.lambda_etl.arn
  handler       = "etl.handler"
  runtime       = "python3.12"

  # ZIPファイルのパスとハッシュ
  filename         = data.archive_file.lambda_etl.output_path
  source_code_hash = data.archive_file.lambda_etl.output_base64sha256

  # メモリとタイムアウト設定
  memory_size = 256
  timeout     = 60

  # AWS提供のPandas Layer（Parquet変換に必要）
  layers = [
    "arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python312:14"
  ]

  # 環境変数でバケット名を渡す
  environment {
    variables = {
      RAW_BUCKET       = aws_s3_bucket.raw.id
      PROCESSED_BUCKET = aws_s3_bucket.processed.id
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-etl"
  })
}
