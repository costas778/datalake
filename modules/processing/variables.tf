
variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the data lake project"
  type        = string
}

variable "raw_bucket_arn" {
  description = "ARN of the raw data bucket"
  type        = string
}

variable "raw_bucket_id" {
  description = "ID of the raw data bucket"
  type        = string
}

variable "processed_bucket_arn" {
  description = "ARN of the processed data bucket"
  type        = string
}

variable "processed_bucket_id" {
  description = "ID of the processed data bucket"
  type        = string
}

variable "curated_bucket_arn" {
  description = "ARN of the curated data bucket"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "crawler_schedule" {
  description = "Cron expression for Glue crawler schedule"
  type        = string
  default     = "cron(0 */6 * * ? *)"  # Run every 6 hours
}

variable "job_schedule" {
  description = "Cron expression for Glue job schedule"
  type        = string
  default     = "cron(0 */12 * * ? *)"  # Run every 12 hours
}

variable "number_of_workers" {
  description = "Number of workers for Glue job"
  type        = number
  default     = 2
}

variable "max_concurrent_runs" {
  description = "Maximum number of concurrent job runs"
  type        = number
  default     = 1
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "random_suffix" {
  description = "Random suffix for unique resource names"
  type        = string
}

variable "glue_database_name" {
  description = "Name of the Glue catalog database"
  type        = string
  default     = null
}
