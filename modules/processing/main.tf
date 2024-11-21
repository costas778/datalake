# IAM Role for Glue
resource "aws_iam_role" "glue_role" {
  name = "${var.project_name}-glue-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Glue
resource "aws_iam_role_policy" "glue_policy" {
  name = "${var.project_name}-glue-policy-${var.environment}"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          var.raw_bucket_arn,
          "${var.raw_bucket_arn}/*",
          var.processed_bucket_arn,
          "${var.processed_bucket_arn}/*",
          var.curated_bucket_arn,
          "${var.curated_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:/aws-glue/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# S3 bucket for Glue scripts
resource "aws_s3_bucket" "glue_scripts" {
  bucket = "${var.project_name}-glue-scripts-${var.environment}"
  tags   = var.tags

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      bucket,
      tags
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "glue_scripts" {
  bucket = aws_s3_bucket.glue_scripts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Glue Database
resource "aws_glue_catalog_database" "data_catalog" {
  name = var.glue_database_name
  
  create_table_default_permission {
    permissions = ["SELECT"]
    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}


# Glue Crawler for Raw Data
resource "aws_glue_crawler" "raw_data" {
  database_name = aws_glue_catalog_database.data_catalog.name
  name          = "${var.project_name}-raw-crawler-${var.environment}"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${var.raw_bucket_id}/raw-data"
  }

  schedule = var.crawler_schedule
  tags     = var.tags
}

# Glue Job for Data Processing
resource "aws_glue_job" "process_raw_data" {
  name              = "${var.project_name}-process-raw-${var.environment}"
  role_arn          = aws_iam_role.glue_role.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = var.number_of_workers

  command {
    script_location = "s3://${aws_s3_bucket.glue_scripts.id}/process_raw_data.py"
    python_version  = "3"
  }

  default_arguments = {
    "--enable-metrics"                = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--job-language"                 = "python"
    "--SOURCE_DATABASE"              = aws_glue_catalog_database.data_catalog.name
    "--TARGET_BUCKET"               = var.processed_bucket_id
  }

  execution_property {
    max_concurrent_runs = var.max_concurrent_runs
  }

  tags = var.tags
}

# CloudWatch Log Group for Glue
resource "aws_cloudwatch_log_group" "glue_logs" {
  name              = "/aws-glue/${var.project_name}-${var.environment}"
  retention_in_days = 30
  tags              = var.tags
}

# CloudWatch Metrics and Alarms
resource "aws_cloudwatch_metric_alarm" "glue_job_failure" {
  alarm_name          = "${var.project_name}-glue-job-failed-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "glue.driver.aggregate.numFailedTasks"
  namespace          = "AWS/Glue"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors Glue job failures"
  alarm_actions      = var.alarm_actions

  dimensions = {
    JobName = aws_glue_job.process_raw_data.name
  }
}

# EventBridge Rule for Scheduling Glue Job
resource "aws_cloudwatch_event_rule" "glue_job_schedule" {
  name                = "${var.project_name}-glue-job-schedule-${var.environment}"
  description         = "Schedule for running the Glue ETL job"
  schedule_expression = var.job_schedule
  tags               = var.tags
}

resource "aws_cloudwatch_event_target" "glue_job_target" {
  rule      = aws_cloudwatch_event_rule.glue_job_schedule.name
  target_id = "GlueJobTarget"
  arn       = "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:job/${aws_glue_job.process_raw_data.name}"
  role_arn  = aws_iam_role.eventbridge_role.arn
}

# IAM Role for EventBridge
resource "aws_iam_role" "eventbridge_role" {
  name = "${var.project_name}-eventbridge-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name = "${var.project_name}-eventbridge-policy-${var.environment}"
  role = aws_iam_role.eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun"
        ]
        Resource = [
          aws_glue_job.process_raw_data.arn
        ]
      }
    ]
  })
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
