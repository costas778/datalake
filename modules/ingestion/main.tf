
# IAM Role for Kinesis Firehose
resource "aws_iam_role" "firehose_role" {
  name = "${var.project_name}-firehose-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Kinesis Firehose
resource "aws_iam_role_policy" "firehose_policy" {
  name = "${var.project_name}-firehose-policy-${var.environment}"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          var.raw_bucket_arn,
          "${var.raw_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# Kinesis Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "data_ingestion" {
  name        = "${var.project_name}-ingestion-stream-${var.environment}"
  destination = "extended_s3"  # Changed from "s3" to "extended_s3"


  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = var.raw_bucket_arn
    prefix             = "raw-data/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/!{firehose:error-output-type}/"
    buffering_size     = var.buffer_size        # Changed from buffer_size
    buffering_interval = var.buffer_interval    # Changed from buffer_interval
    compression_format = "GZIP"
  }

  tags = var.tags
}

# CloudWatch Log Group for Firehose
resource "aws_cloudwatch_log_group" "firehose_logs" {
  name              = "/aws/firehose/${aws_kinesis_firehose_delivery_stream.data_ingestion.name}"
  retention_in_days = 30
  tags              = var.tags
}

# Transfer Family SFTP Server (Optional)
resource "aws_transfer_server" "sftp" {
  count = var.enable_sftp ? 1 : 0
  
  identity_provider_type = "SERVICE_MANAGED"
  protocols             = ["SFTP"]
  domain               = "S3"
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-sftp-server-${var.environment}"
  })
}

# SFTP User (Optional)
resource "aws_transfer_user" "sftp_user" {
  count = var.enable_sftp ? 1 : 0
  
  server_id = aws_transfer_server.sftp[0].id
  user_name = var.sftp_username
  role      = aws_iam_role.transfer_user_role[0].arn

  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${var.raw_bucket_id}/sftp-uploads"
  }
}

# IAM Role for Transfer Family User (Optional)
resource "aws_iam_role" "transfer_user_role" {
  count = var.enable_sftp ? 1 : 0
  
  name = "${var.project_name}-transfer-user-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Metrics and Alarms
resource "aws_cloudwatch_metric_alarm" "firehose_delivery_failed" {
  alarm_name          = "${var.project_name}-firehose-delivery-failed-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "DeliveryToS3.Failed"
  namespace          = "AWS/Firehose"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors failed deliveries to S3"
  alarm_actions      = var.alarm_actions

  dimensions = {
    DeliveryStreamName = aws_kinesis_firehose_delivery_stream.data_ingestion.name
  }
}

variable "random_suffix" {
  description = "Random suffix for unique resource names"
  type        = string
}

