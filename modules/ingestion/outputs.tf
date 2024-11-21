output "kinesis_firehose_name" {
  description = "Name of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.data_ingestion.name
}

output "kinesis_firehose_arn" {
  description = "ARN of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.data_ingestion.arn
}

output "sftp_endpoint" {
  description = "SFTP endpoint for file uploads"
  value       = var.enable_sftp ? aws_transfer_server.sftp[0].endpoint : null
}

output "firehose_role_arn" {
  description = "ARN of the IAM role used by Kinesis Firehose"
  value       = aws_iam_role.firehose_role.arn
}
