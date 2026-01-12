# cloudwatch.tf

# ================================
# CloudWatch監視
# ================================

# Lambda用ロググループ
# Lambda関数のログを保存（14日間保持）
resource "aws_cloudwatch_log_group" "lambda_etl" {
  name              = "/aws/lambda/${aws_lambda_function.etl.function_name}"
  retention_in_days = 14

  tags = local.common_tags
}

# Lambdaエラーアラーム
# Lambda ETLのエラーを検知してSNS通知
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project}-lambda-errors"
  alarm_description   = "Lambda ETLのエラーを検知"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300 # 5分
  statistic           = "Sum"
  threshold           = 1

  # 監視対象のLambda関数を指定
  dimensions = {
    FunctionName = aws_lambda_function.etl.function_name
  }

  # アラーム発生時・復旧時にSNS通知
  alarm_actions = [aws_sns_topic.alert.arn]
  ok_actions    = [aws_sns_topic.alert.arn]

  tags = local.common_tags
}
