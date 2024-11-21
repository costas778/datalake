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

variable "glue_database_name" {
  description = "Name of the Glue catalog database"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "create_example_table" {
  description = "Create example Glue catalog table"
  type        = bool
  default     = false
}

variable "shared_account_ids" {
  description = "List of AWS account IDs to share data with"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Number of days to retain audit logs"
  type        = number
  default     = 90
}

variable "random_suffix" {
  description = "Random suffix for unique resource names"
  type        = string
}
