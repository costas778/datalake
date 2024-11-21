output "raw_bucket_name" {
  description = "Name of the raw data bucket"
  value       = aws_s3_bucket.raw.id
}

output "raw_bucket_arn" {
  description = "ARN of the raw data bucket"
  value       = aws_s3_bucket.raw.arn
}

output "processed_bucket_name" {
  description = "Name of the processed data bucket"
  value       = aws_s3_bucket.processed.id
}

output "processed_bucket_arn" {
  description = "ARN of the processed data bucket"
  value       = aws_s3_bucket.processed.arn
}

output "curated_bucket_name" {
  description = "Name of the curated data bucket"
  value       = aws_s3_bucket.curated.id
}

output "curated_bucket_arn" {
  description = "ARN of the curated data bucket"
  value       = aws_s3_bucket.curated.arn
}
