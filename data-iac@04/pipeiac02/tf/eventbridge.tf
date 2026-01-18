# eventbridge.tf

# ================================
# EventBridge（イベント駆動）
# ================================

# S3バケットのEventBridge通知を有効化
# S3へのアップロードをEventBridgeに通知する設定
resource "aws_s3_bucket_notification" "raw" {
  bucket      = aws_s3_bucket.raw.id
  eventbridge = true
}

# EventBridge Rule
# S3へのファイルアップロードを検知するルール
resource "aws_cloudwatch_event_rule" "s3_upload" {
  name        = "${var.project}-s3-upload"
  description = "S3 Rawバケットへのファイルアップロードを検知"

  # イベントパターン：input/配下へのオブジェクト作成を検知
  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = { name = [aws_s3_bucket.raw.id] }
      object = { key = [{ prefix = "input/" }] }
    }
  })

  tags = merge(local.common_tags, {
    Name = "${var.project}-s3-upload"
  })
}

# EventBridge Target
# 検知したイベントでStep Functionsを起動
resource "aws_cloudwatch_event_target" "sfn" {
  rule     = aws_cloudwatch_event_rule.s3_upload.name
  arn      = aws_sfn_state_machine.pipeline.arn
  role_arn = aws_iam_role.eventbridge.arn

  # 入力変換：S3イベントからinput_keyを抽出してStep Functionsに渡す
  input_transformer {
    input_paths = {
      s3_key = "$.detail.object.key"
    }
    input_template = "{\"input_key\": <s3_key>}"
  }
}
