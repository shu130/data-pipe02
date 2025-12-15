# ================================
# Lambda関数
# ================================

# Pythonコードをzip化
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

# Lambda関数
resource "aws_lambda_function" "etl" {
  function_name = "${var.project}-etl-function"
  role          = aws_iam_role.lambda.arn

  # zip化したコードをアップロード
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  # 実行環境の設定
  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"

  # リソース設定
  timeout     = 60   # 最大実行時間（秒）
  memory_size = 256  # メモリ割り当て（MB）

  # 環境変数（Pythonコードから参照）
  environment {
    variables = {
      RAW_BUCKET       = aws_s3_bucket.raw.bucket
      PROCESSED_BUCKET = aws_s3_bucket.processed.bucket
    }
  }

  tags = local.common_tags
}
