
output "athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  value       = aws_athena_workgroup.analytics.name
}

output "athena_workgroup_arn" {
  description = "ARN of the Athena workgroup"
  value       = aws_athena_workgroup.analytics.arn
}

output "athena_results_bucket" {
  description = "Name of the Athena results bucket"
  value       = aws_s3_bucket.athena_results.id
}

output "quicksight_role_arn" {
  description = "ARN of the QuickSight IAM role"
  value       = aws_iam_role.quicksight_role.arn
}

output "analytics_dashboard_name" {
  description = "Name of the CloudWatch dashboard for analytics"
  value       = aws_cloudwatch_dashboard.analytics.dashboard_name
}
