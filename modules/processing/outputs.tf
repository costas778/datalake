
output "glue_database_name" {
  description = "Name of the Glue catalog database"
  value       = aws_glue_catalog_database.data_catalog.name
}

output "glue_job_name" {
  description = "Name of the Glue ETL job"
  value       = aws_glue_job.process_raw_data.name
}

output "glue_job_arn" {
  description = "ARN of the Glue ETL job"
  value       = aws_glue_job.process_raw_data.arn
}

output "glue_crawler_name" {
  description = "Name of the Glue crawler"
  value       = aws_glue_crawler.raw_data.name
}

output "glue_scripts_bucket" {
  description = "Name of the S3 bucket containing Glue scripts"
  value       = aws_s3_bucket.glue_scripts.id
}
