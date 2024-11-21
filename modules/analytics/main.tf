# S3 bucket for Athena query results
resource "aws_s3_bucket" "athena_results" {
  bucket = "${var.project_name}-athena-results-${var.environment}-${var.random_suffix}"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket = "${var.project_name}-athena-results-${var.environment}-${var.random_suffix}"  # This has the random suffix
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Athena Workgroup
resource "aws_athena_workgroup" "analytics" {
  name = "${var.project_name}-workgroup-${var.environment}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/output/"
      
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  tags = var.tags
}

# IAM Role for QuickSight
resource "aws_iam_role" "quicksight_role" {
  name = "${var.project_name}-quicksight-role-${var.environment}"

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

# IAM Policy for QuickSight
resource "aws_iam_role_policy" "quicksight_policy" {
  name = "${var.project_name}-quicksight-policy-${var.environment}"
  role = aws_iam_role.quicksight_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.processed_bucket_arn,
          "${var.processed_bucket_arn}/*",
          var.curated_bucket_arn,
          "${var.curated_bucket_arn}/*",
          aws_s3_bucket.athena_results.arn,
          "${aws_s3_bucket.athena_results.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:GetWorkGroup",
          "athena:StopQueryExecution"
        ]
        Resource = [
          aws_athena_workgroup.analytics.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetDatabase",
          "glue:GetDatabases"
        ]
        Resource = [
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/*",
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/*"
        ]
      }
    ]
  })
}

# Named Queries for common analytics
resource "aws_athena_named_query" "example_query" {
  count = var.create_example_queries ? 1 : 0

  name        = "example-daily-metrics"
  workgroup   = aws_athena_workgroup.analytics.name
  database    = var.glue_database_name
  description = "Example query for daily metrics"
  query       = <<EOF
SELECT 
  date_trunc('day', timestamp_column) as day,
  count(*) as daily_count,
  sum(metric_value) as daily_sum
FROM processed_table
GROUP BY date_trunc('day', timestamp_column)
ORDER BY day DESC
LIMIT 30;
EOF
}

# CloudWatch Dashboard for Analytics
resource "aws_cloudwatch_dashboard" "analytics" {
  dashboard_name = "${var.project_name}-analytics-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Athena", "ProcessedBytes", "WorkGroup", aws_athena_workgroup.analytics.name],
            ["AWS/Athena", "QueryExecutionTime", "WorkGroup", aws_athena_workgroup.analytics.name]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Athena Query Metrics"
        }
      }
    ]
  })
}

# CloudWatch Alarms for Analytics
resource "aws_cloudwatch_metric_alarm" "query_failed" {
  alarm_name          = "${var.project_name}-query-failed-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "QueryFailed"
  namespace          = "AWS/Athena"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors failed Athena queries"
  alarm_actions      = var.alarm_actions

  dimensions = {
    WorkGroup = aws_athena_workgroup.analytics.name
  }
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

