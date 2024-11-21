variable "environment" {
   description = "Environment (dev, staging, prod)"
   type        = string
 }
 
 variable "project_name" {
   description = "Name of the data lake project"
   type        = string
 }
 
 variable "raw_bucket_name" {
   description = "Name of the raw data bucket"
   type        = string
 }
 
 variable "processed_bucket_name" {
   description = "Name of the processed data bucket"
   type        = string
 }
 
 variable "curated_bucket_name" {
   description = "Name of the curated data bucket"
   type        = string
 }
 
 variable "tags" {
   description = "Common tags for all resources"
   type        = map(string)
   default     = {}
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
 
 variable "random_suffix" {
   description = "Random suffix for unique resource names"
   type        = string
 }
 