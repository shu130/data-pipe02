# iam.tf

# ================================
# Lambda ETL用IAM
# ================================

# Lambda ETL用IAMロール
# LambdaがS3にアクセスするための権限を付与
resource "aws_iam_role" "lambda_etl" {
  name = "${var.project}-lambda-etl-role"

  # Lambda用の信頼ポリシー
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project}-lambda-etl-role"
  })
}

# Lambda用S3アクセスポリシー（最小権限）
# Rawバケットからの読み込み、Processedバケットへの書き込みのみ許可
resource "aws_iam_policy" "lambda_s3" {
  name        = "${var.project}-lambda-s3-policy"
  description = "Lambda ETL用S3アクセスポリシー"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadRawBucket"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["${aws_s3_bucket.raw.arn}/*"]
      },
      {
        Sid      = "WriteProcessedBucket"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["${aws_s3_bucket.processed.arn}/*"]
      }
    ]
  })

  tags = local.common_tags
}

# Lambda S3ポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_etl.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

# CloudWatch Logs出力用マネージドポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_etl.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ================================
# Glue Crawler用IAM
# ================================

# Glue Crawler用IAMロール
# Glue CrawlerがS3にアクセスするための権限を付与
resource "aws_iam_role" "glue_crawler" {
  name = "${var.project}-glue-crawler-role"

  # Glue用の信頼ポリシー
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project}-glue-crawler-role"
  })
}

# Glue Crawler用S3アクセスポリシー（最小権限）
# Processedバケットの読み込みとリスト取得のみ許可
resource "aws_iam_policy" "glue_s3" {
  name        = "${var.project}-glue-s3-policy"
  description = "Glue Crawler用S3アクセスポリシー"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadProcessedBucket"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["${aws_s3_bucket.processed.arn}/*"]
      },
      {
        Sid      = "ListProcessedBucket"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = [aws_s3_bucket.processed.arn]
      }
    ]
  })

  tags = local.common_tags
}

# Glue S3ポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "glue_s3" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = aws_iam_policy.glue_s3.arn
}

# Glue基本権限マネージドポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# ================================
# Step Functions用IAM
# ================================

# Step Functions用IAMロール
# Step FunctionsがLambda、Glue、SNSを操作するための権限を付与
resource "aws_iam_role" "sfn" {
  name = "${var.project}-sfn-role"

  # Step Functions用の信頼ポリシー
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project}-sfn-role"
  })
}

# Step Functions用ポリシー（最小権限）
# Lambda実行、Glue Crawler起動、SNS通知のみ許可
resource "aws_iam_policy" "sfn" {
  name        = "${var.project}-sfn-policy"
  description = "Step Functions用ポリシー"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "InvokeLambda"
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = [aws_lambda_function.etl.arn]
      },
      {
        Sid      = "StartGlueCrawler"
        Effect   = "Allow"
        Action   = ["glue:StartCrawler", "glue:GetCrawler"]
        Resource = ["arn:aws:glue:${var.aws_region}:*:crawler/${aws_glue_crawler.main.name}"]
      },
      {
        Sid      = "PublishSNS"
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = [aws_sns_topic.alert.arn]
      }
    ]
  })

  tags = local.common_tags
}

# Step Functionsポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "sfn" {
  role       = aws_iam_role.sfn.name
  policy_arn = aws_iam_policy.sfn.arn
}

# ================================
# EventBridge用IAM
# ================================

# EventBridge用IAMロール
# EventBridgeがStep Functionsを起動するための権限を付与
resource "aws_iam_role" "eventbridge" {
  name = "${var.project}-eventbridge-role"

  # EventBridge用の信頼ポリシー
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "events.amazonaws.com" }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project}-eventbridge-role"
  })
}

# EventBridge用ポリシー（最小権限）
# 特定のStep Functions State Machineの実行開始のみ許可
resource "aws_iam_policy" "eventbridge" {
  name        = "${var.project}-eventbridge-policy"
  description = "EventBridge用ポリシー"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "StartStepFunctions"
        Effect   = "Allow"
        Action   = ["states:StartExecution"]
        Resource = [aws_sfn_state_machine.pipeline.arn]
      }
    ]
  })

  tags = local.common_tags
}

# EventBridgeポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "eventbridge" {
  role       = aws_iam_role.eventbridge.name
  policy_arn = aws_iam_policy.eventbridge.arn
}
