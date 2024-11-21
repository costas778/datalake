# Raw Data Zone Bucket
  resource "aws_s3_bucket" "raw" {
  bucket = var.raw_bucket_name
  tags   = merge(var.tags, { "Zone" = "Raw" })

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      bucket,
      tags
    ]
  }
}
 
 resource "aws_s3_bucket_versioning" "raw" {
   bucket = aws_s3_bucket.raw.id
   versioning_configuration {
     status = var.enable_versioning ? "Enabled" : "Disabled"
   }
 }
 
 resource "aws_s3_bucket_server_side_encryption_configuration" "raw" {
   bucket = aws_s3_bucket.raw.id
 
   rule {
     apply_server_side_encryption_by_default {
       sse_algorithm = "AES256"
     }
   }
 }
 
 resource "aws_s3_bucket_lifecycle_configuration" "raw" {
   bucket = aws_s3_bucket.raw.id
 
   rule {
     id     = "transition_to_ia"
     status = "Enabled"
 
     transition {
       days          = var.retention_days
       storage_class = "STANDARD_IA"
     }
   }
 }
 
 # Processed Data Zone Bucket
 resource "aws_s3_bucket" "processed" {
   bucket = var.processed_bucket_name
   tags   = merge(var.tags, { "Zone" = "Processed" })
 }
 
 resource "aws_s3_bucket_versioning" "processed" {
   bucket = aws_s3_bucket.processed.id
   versioning_configuration {
     status = var.enable_versioning ? "Enabled" : "Disabled"
   }
 }
 
 resource "aws_s3_bucket_server_side_encryption_configuration" "processed" {
   bucket = aws_s3_bucket.processed.id
 
   rule {
     apply_server_side_encryption_by_default {
       sse_algorithm = "AES256"
     }
   }
 }
 
 # Curated Data Zone Bucket
 resource "aws_s3_bucket" "curated" {
   bucket = var.curated_bucket_name
   tags   = merge(var.tags, { "Zone" = "Curated" })
 }
 
 resource "aws_s3_bucket_versioning" "curated" {
   bucket = aws_s3_bucket.curated.id
   versioning_configuration {
     status = var.enable_versioning ? "Enabled" : "Disabled"
   }
 }
 
 resource "aws_s3_bucket_server_side_encryption_configuration" "curated" {
   bucket = aws_s3_bucket.curated.id
 
   rule {
     apply_server_side_encryption_by_default {
       sse_algorithm = "AES256"
     }
   }
 }
 
 # Block Public Access for all buckets
 resource "aws_s3_bucket_public_access_block" "raw" {
   bucket = aws_s3_bucket.raw.id
 
   block_public_acls       = true
   block_public_policy     = true
   ignore_public_acls      = true
   restrict_public_buckets = true
 }
 
 resource "aws_s3_bucket_public_access_block" "processed" {
   bucket = aws_s3_bucket.processed.id
 
   block_public_acls       = true
   block_public_policy     = true
   ignore_public_acls      = true
   restrict_public_buckets = true
 }
 
 resource "aws_s3_bucket_public_access_block" "curated" {
   bucket = aws_s3_bucket.curated.id
 
   block_public_acls       = true
   block_public_policy     = true
   ignore_public_acls      = true
   restrict_public_buckets = true
 }
 
