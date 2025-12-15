# ================================
# Lambda用 IAMロール・ポリシー
# ================================

# Lambdaがこのロールを使えるようにする（信頼ポリシー）
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Lambda用ロール
resource "aws_iam_role" "lambda" {
  name               = "${var.project}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.common_tags
}

# Lambdaに与える権限（S3読み書き、ログ出力）
data "aws_iam_policy_document" "lambda_policy" {
  # S3 rawからデータ取得
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.raw.arn}/*"]
  }

  # S3 processedにデータ保存
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.processed.arn}/*"]
  }

  # CloudWatchログ出力
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

# ポリシーをロールにアタッチ
resource "aws_iam_role_policy" "lambda" {
  name   = "${var.project}-lambda-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

# ================================
# Glue Crawler用 IAMロール・ポリシー
# ================================

# GlueがこのロールをAssumeできるようにする（信頼ポリシー）
data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

# Glue Crawler用ロール
resource "aws_iam_role" "glue_crawler" {
  name               = "${var.project}-glue-crawler-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json

  tags = local.common_tags
}

# Glue Crawlerに与える権限（S3読み取り、Glueカタログ操作）
data "aws_iam_policy_document" "glue_crawler_policy" {
  # S3 processedからデータ取得
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.processed.arn}/*"]
  }

  # S3 processedのファイル一覧取得
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.processed.arn]
  }

  # Glueカタログの操作
  statement {
    actions   = ["glue:*"]
    resources = ["*"]
  }

  # CloudWatchログ出力
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

# ポリシーをロールにアタッチ
resource "aws_iam_role_policy" "glue_crawler" {
  name   = "${var.project}-glue-crawler-policy"
  role   = aws_iam_role.glue_crawler.id
  policy = data.aws_iam_policy_document.glue_crawler_policy.json
}

# ================================
# Step Functions用 IAMロール・ポリシー
# ================================

# Step FunctionsがこのロールをAssumeできるようにする（信頼ポリシー）
data "aws_iam_policy_document" "sfn_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

# Step Functions用ロール
resource "aws_iam_role" "sfn" {
  name               = "${var.project}-sfn-role"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role.json

  tags = local.common_tags
}

# Step Functionsに与える権限（Lambda実行、Crawler実行）
data "aws_iam_policy_document" "sfn_policy" {
  # Lambda実行
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.etl.arn]
  }

  # Glue Crawler実行・状態確認
  statement {
    actions = [
      "glue:StartCrawler",
      "glue:GetCrawler"
    ]
    resources = ["*"]
  }
}

# ポリシーをロールにアタッチ
resource "aws_iam_role_policy" "sfn" {
  name   = "${var.project}-sfn-policy"
  role   = aws_iam_role.sfn.id
  policy = data.aws_iam_policy_document.sfn_policy.json
}
