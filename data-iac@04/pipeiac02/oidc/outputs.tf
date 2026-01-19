# oidc/outputs.tf

# ================================
# 出力
# ================================

output "oidc_provider_arn" {
  description = "OIDCプロバイダのARN"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions用IAMロールのARN"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "GitHub Actions用IAMロール名"
  value       = aws_iam_role.github_actions.name
}
