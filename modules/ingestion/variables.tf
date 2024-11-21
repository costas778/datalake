
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

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "buffer_size" {
  description = "Buffer size in MBs for Kinesis Firehose"
  type        = number
  default     = 5
}

variable "buffer_interval" {
  description = "Buffer interval in seconds for Kinesis Firehose"
  type        = number
  default     = 300
}

variable "enable_sftp" {
  description = "Enable SFTP server for file uploads"
  type        = bool
  default     = false
}

variable "sftp_username" {
  description = "Username for SFTP server"
  type        = string
  default     = "datalake-user"
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}
