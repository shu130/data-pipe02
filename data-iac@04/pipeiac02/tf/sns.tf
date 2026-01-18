# sns.tf

# ================================
# SNS（通知）
# ================================

# SNS Topic（アラート通知用）
# パイプライン失敗時やLambdaエラー時の通知先
resource "aws_sns_topic" "alert" {
  name = "${var.project}-alert"

  tags = merge(local.common_tags, {
    Name = "${var.project}-alert"
  })
}

# SNS Subscription（メール通知）
# 指定したメールアドレスに通知を送信
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alert.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
