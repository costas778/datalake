output "raw_bucket_name" {
  description = "Name of the raw data bucket"
  value       = module.storage.raw_bucket_name
}

output "processed_bucket_name" {
  description = "Name of the processed data bucket"
  value       = module.storage.processed_bucket_name
}

output "curated_bucket_name" {
  description = "Name of the curated data bucket"
  value       = module.storage.curated_bucket_name
}

output "glue_catalog_database_name" {
  description = "Name of the Glue catalog database"
  value       = module.governance.glue_database_name
}

output "kinesis_firehose_name" {
  description = "Name of the Kinesis Firehose delivery stream"
  value       = module.ingestion.kinesis_firehose_name
}

output "glue_job_name" {
  description = "Name of the main Glue ETL job"
  value       = module.processing.glue_job_name
}

output "athena_workgroup" {
  description = "Name of the Athena workgroup"
  value       = module.analytics.athena_workgroup_name
}
