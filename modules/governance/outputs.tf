output "lakeformation_admin_role_arn" {
  description = "ARN of the Lake Formation admin role"
  value       = aws_iam_role.lakeformation_role.arn
}

output "data_analyst_role_arn" {
  description = "ARN of the data analyst role"
  value       = aws_iam_role.data_analyst_role.arn
}

output "catalog_kms_key_arn" {
  description = "ARN of the KMS key used for catalog encryption"
  value       = aws_kms_key.catalog_key.arn
}

output "governance_log_group" {
  description = "Name of the CloudWatch log group for governance audit"
  value       = aws_cloudwatch_log_group.governance_audit.name
}

output "config_rules" {
  description = "List of AWS Config rule names"
  value = [
    aws_config_config_rule.s3_encryption.name,
    aws_config_config_rule.s3_public_access.name
  ]
}

output "glue_database_name" {
  description = "Name of the Glue catalog database"
  value       = var.glue_database_name
}


