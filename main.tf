/*resource "aws_kms_alias" "app" {
  description = "Key for 'Xiaomi Mi Home Security Camera 360 Backup' project"
  deletion_window_in_days = 30
  tags = merge(var.tags, map("Name", join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "all"])))
}*/

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "all"])
  region = var.region
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = data.aws_kms_alias.s3.arn
      }
    }
  }
  lifecycle_rule {
    id      = "upload-to-deep-archive-directly"
    enabled = true
    transition {
      days          = 0
      storage_class = "DEEP_ARCHIVE"
    }
    expiration {
      days = 180
    }
  }

  tags   = merge(var.tags, map("Name", join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "all"])))
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = "${aws_s3_bucket.main.id}"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SQS queue
resource "aws_sqs_queue" "main" {
  name                        = "${join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "pri"])}"
  #kms_master_key_id           = data.aws_kms_alias.lambda.arn
  max_message_size            = 2048
  visibility_timeout_seconds  = 20
  message_retention_seconds   = 300
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:${join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "pri"])}",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.main.arn}" }
      }
    }
  ]
}
POLICY
  tags = merge(var.tags, map("Name", join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "all"])))
}

# Send a SQS message when a file is uploaded
resource "aws_s3_bucket_notification" "sqs" {
  bucket = aws_s3_bucket.main.id
  queue {
    id            = "upload-video"
    queue_arn     = "${aws_sqs_queue.main.arn}"
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "upload/"
    filter_suffix = ".mp4"
  }
}

# DynamoDB

resource "aws_dynamodb_table" "main" {
  name           = join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "all"])
  billing_mode   = "PROVISIONED"
  read_capacity  = "1"
  write_capacity = "1"

  hash_key       = "Id"
  #range_key      = ""
  
  #server_side_encryption {
  #  enabled = true
  #}
  
  attribute {
    name = "Id"
    type = "S"
  }

  tags           = merge(var.tags, map("Name", join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "all"])))
}

# Lambda function
resource "aws_lambda_function" "main" {
  filename                       = "${path.module}/files/s3-storage.zip"
  description                    = "Lambda used to store Mi Home 360 video"
  function_name                  = join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "all"])
  role                           = aws_iam_role.lambda.arn
  handler                        = "s3-storage.handler"
  source_code_hash               = data.archive_file.main.output_base64sha256
  runtime                        = "python3.7"
  kms_key_arn                    = data.aws_kms_alias.lambda.target_key_arn
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      BUCKET_NAME         = aws_s3_bucket.main.bucket
      SQS_URL             = aws_sqs_queue.main.id
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.main.id
    }
  }
  tags = merge(var.tags, map("Name", join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "all"])))
}

# Run Lambda function for each SQS message
resource "aws_lambda_event_source_mapping" "sqs-to-lambda" {
  event_source_arn = "${aws_sqs_queue.main.arn}"
  function_name    = "${aws_lambda_function.main.arn}"
}
