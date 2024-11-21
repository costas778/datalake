provider "aws" {
  region = var.aws_region
}

provider "random" {}

# Storage Module - S3 buckets for raw, processed, and curated data
module "storage" {
  source                = "./modules/storage"
  environment           = var.environment
  project_name          = var.project_name
  raw_bucket_name       = "${var.project_name}-raw-${var.environment}"
  processed_bucket_name = "${var.project_name}-processed-${var.environment}"
  curated_bucket_name   = "${var.project_name}-curated-${var.environment}"
  random_suffix         = random_string.suffix.result # Add this line
}

# Data Ingestion Module
module "ingestion" {
  source         = "./modules/ingestion"
  environment    = var.environment
  project_name   = var.project_name
  raw_bucket_arn = module.storage.raw_bucket_arn
  raw_bucket_id  = module.storage.raw_bucket_name
  random_suffix  = random_string.suffix.result # Add this line
}

# Data Processing Module
module "processing" {
  source = "./modules/processing"

  environment          = var.environment
  project_name         = var.project_name
  raw_bucket_arn       = module.storage.raw_bucket_arn
  raw_bucket_id        = module.storage.raw_bucket_name # Added this line
  processed_bucket_arn = module.storage.processed_bucket_arn
  processed_bucket_id  = module.storage.processed_bucket_name # Added this line
  curated_bucket_arn   = module.storage.curated_bucket_arn
  random_suffix        = random_string.suffix.result # Add this line
  glue_database_name = "${var.project_name}_catalog_${var.environment}"
}


module "governance" {
  source = "./modules/governance"

  environment          = var.environment
  project_name         = var.project_name
  raw_bucket_arn       = module.storage.raw_bucket_arn
  raw_bucket_id        = module.storage.raw_bucket_name # Changed from raw_bucket_id
  processed_bucket_arn = module.storage.processed_bucket_arn
  processed_bucket_id  = module.storage.processed_bucket_name # Changed from processed_bucket_id
  curated_bucket_arn   = module.storage.curated_bucket_arn
  glue_database_name   = var.glue_database_name
  random_suffix        = random_string.suffix.result # Add this line
}

# Analytics Module
module "analytics" {
  source = "./modules/analytics"

  environment          = var.environment
  project_name         = var.project_name
  processed_bucket_arn = module.storage.processed_bucket_arn
  curated_bucket_arn   = module.storage.curated_bucket_arn
  glue_database_name   = var.glue_database_name
  random_suffix        = random_string.suffix.result
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}


