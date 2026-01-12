# stepfunctions.tf

# ================================
# Step Functions
# ================================

# State Machine（パイプライン）
# Lambda ETL → Glue Crawler の順序でワークフローを実行
resource "aws_sfn_state_machine" "pipeline" {
  name     = "${var.project}-pipeline"
  role_arn = aws_iam_role.sfn.arn

  # ワークフロー定義（ASL: Amazon States Language）
  definition = jsonencode({
    Comment = "Data Pipeline Workflow"
    StartAt = "ETL"
    States = {
      # ETL処理（Lambda実行）
      ETL = {
        Type     = "Task"
        Resource = aws_lambda_function.etl.arn
        Next     = "StartCrawler"
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "NotifyFailure"
        }]
      }
      # Glue Crawler起動（同期実行）
      StartCrawler = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startCrawler.sync"
        Parameters = {
          Name = aws_glue_crawler.main.name
        }
        Next = "Success"
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "NotifyFailure"
        }]
      }
      # 成功終了
      Success = {
        Type = "Succeed"
      }
      # 失敗通知（SNS）
      NotifyFailure = {
        Type     = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn    = aws_sns_topic.alert.arn
          "Message.$" = "States.Format('Pipeline failed: {}', $.Error)"
        }
        Next = "Fail"
      }
      # 失敗終了
      Fail = {
        Type = "Fail"
      }
    }
  })

  tags = merge(local.common_tags, {
    Name = "${var.project}-pipeline"
  })
}
