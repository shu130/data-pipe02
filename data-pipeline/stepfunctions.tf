# ================================
# Step Functions ステートマシン
# ================================

resource "aws_sfn_state_machine" "pipeline" {
  name     = "${var.project}-state-machine"
  role_arn = aws_iam_role.sfn.arn

  # ワークフローの定義（JSON形式）
  definition = jsonencode({
    Comment = "ETL Pipeline: Lambda → Glue Crawler"
    StartAt = "RunETL"

    States = {
      # ステップ1: Lambda実行（JSON → CSV変換）
      RunETL = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.etl.arn
          Payload = {
            "input_key.$" = "$.input_key"
          }
        }
        ResultPath = "$.etl_result"
        Next       = "RunCrawler"
      }

      # ステップ2: Glue Crawler実行（テーブル定義作成）
      RunCrawler = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startCrawler.sync"
        Parameters = {
          Name = aws_glue_crawler.processed.name
        }
        End = true
      }
    }
  })

  tags = local.common_tags
}
