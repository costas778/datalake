# Lake Formation Admin Settings

resource "aws_lakeformation_data_lake_settings" "settings" {
  admins = [data.aws_caller_identity.current.arn]
}

# Lake Formation Resource Registration
resource "aws_lakeformation_resource" "raw_bucket" {
  arn = var.raw_bucket_arn
}

resource "aws_lakeformation_resource" "processed_bucket" {
  arn = var.processed_bucket_arn
}

resource "aws_lakeformation_resource" "curated_bucket" {
  arn = var.curated_bucket_arn
}


# IAM Role for Lake Formation
resource "aws_iam_role" "lakeformation_role" {
  name = "${var.project_name}-lakeformation-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lakeformation.amazonaws.com"
        }
      }
    ]
  })
}


# Lake Formation Permissions
resource "aws_lakeformation_permissions" "data_analyst_permissions" {
  principal        = aws_iam_role.data_analyst_role.arn
  permissions      = ["SELECT"]
  
  database {
    name       = var.glue_database_name
    catalog_id = data.aws_caller_identity.current.account_id
  }
}


# IAM Role for Data Analysts
resource "aws_iam_role" "data_analyst_role" {
  name = "${var.project_name}-data-analyst-role-${var.environment}-${var.random_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "quicksight.amazonaws.com"
        }
      }
    ]
  })
}

# Tags for Data Catalog
resource "aws_glue_catalog_table" "example_table" {
  count = var.create_example_table ? 1 : 0

  database_name = var.glue_database_name
  name          = "example_table"
  
  parameters = {
    "classification" = "csv"
    "data_owner"    = "data_team"
    "sensitivity"   = "confidential"
  }

  storage_descriptor {
    location      = "s3://${var.processed_bucket_id}/example/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
    }
  }
}

# AWS RAM Resource Share for Cross-Account Access
resource "aws_ram_resource_share" "data_share" {
  count = length(var.shared_account_ids) > 0 ? 1 : 0

  name                      = "${var.project_name}-data-share-${var.environment}-${var.random_suffix}"
  allow_external_principals = true
  tags                     = var.tags
}

# CloudWatch Logs for Audit
resource "aws_cloudwatch_log_group" "governance_audit" {
  name = "/aws/lakeformation/${var.project_name}-audit-${var.environment}-${var.random_suffix}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# AWS Config Rule for S3 Encryption
resource "aws_config_config_rule" "s3_encryption" {
  name = "${var.project_name}-s3-encryption-${var.environment}-${var.random_suffix}"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
  }

  tags = var.tags
  depends_on = [aws_config_configuration_recorder_status.recorder_status]
}

# AWS Config Rule for S3 Public Access
resource "aws_config_config_rule" "s3_public_access" {
  name = "${var.project_name}-s3-public-access-${var.environment}-${var.random_suffix}"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
  }

  tags = var.tags
  depends_on = [aws_config_configuration_recorder_status.recorder_status]
}


# Data Catalog Encryption
resource "aws_glue_data_catalog_encryption_settings" "example" {
  data_catalog_encryption_settings {
    encryption_at_rest {
      catalog_encryption_mode = "SSE-KMS"
      sse_aws_kms_key_id     = aws_kms_key.catalog_key.arn
    }

    connection_password_encryption {
      return_connection_password_encrypted = true
      aws_kms_key_id                      = aws_kms_key.catalog_key.arn
    }
  }
}



# KMS Key for Data Catalog Encryption
resource "aws_kms_key" "catalog_key" {
  description             = "KMS key for Data Catalog encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_kms_alias" "catalog_key" {
  name = "alias/${var.project_name}-catalog-key-${var.environment}-${var.random_suffix}"
  target_key_id = aws_kms_key.catalog_key.key_id
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role_policy" "lakeformation_admin" {
  name = "${var.project_name}-lakeformation-role-${var.environment}-${var.random_suffix}"
  role = aws_iam_role.lakeformation_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lakeformation:PutDataLakeSettings",
          "lakeformation:RegisterResource",
          "lakeformation:GrantPermissions",
          "lakeformation:GetDataLakeSettings",
          "lakeformation:GetResource"
        ]
        Resource = "*"
      }
    ]
  })
}




# Config Role
resource "aws_iam_role" "config_role" {
  name = "${var.project_name}-config-role-${var.environment}-${var.random_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "config_policy" {
  name = "${var.project_name}-config-policy-${var.environment}"
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "config:Put*",
          "config:Get*",
          "config:List*",
          "config:Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_config_configuration_recorder" "recorder" {
  name     = "${var.project_name}-config-recorder-${var.environment}-${var.random_suffix}"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    recording_strategy {
      use_only = "ALL_SUPPORTED_RESOURCE_TYPES"
    }
  }
}



resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
  depends_on = [aws_config_configuration_recorder.recorder, aws_config_delivery_channel.delivery_channel]
}


resource "aws_config_delivery_channel" "delivery_channel" {
  name           = "${var.project_name}-delivery-channel-${var.environment}-${var.random_suffix}"
  s3_bucket_name = aws_s3_bucket.config_bucket.id

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "${var.project_name}-config-${var.environment}-${var.random_suffix}"
  tags   = var.tags
}


