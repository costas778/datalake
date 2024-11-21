variable "aws_region" {
  description = "AWS Region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the data lake project"
  type        = string
  default     = "datalake"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "Data Lake"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "retention_days" {
  description = "Number of days to retain data in raw zone before transitioning"
  type        = number
  default     = 90
}

variable "enable_versioning" {
  description = "Enable versioning on S3 buckets"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption on S3 buckets"
  type        = bool
  default     = true
}

variable "glue_database_name" {
  description = "Name of the Glue database"
  type        = string
  default     = "datalake-dev" # You can set a default value or remove this line if you want it to be required
}


