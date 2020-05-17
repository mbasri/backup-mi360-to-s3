data "aws_caller_identity" "current" {
  
}

# KMS keys
data "aws_kms_alias" "lambda" {
  name = "alias/aws/lambda"
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

data "aws_kms_alias" "sqs" {
  name = "alias/aws/sqs"
}

data "aws_kms_alias" "dynamodb" {
  name = "alias/aws/dynamodb"
}

data "aws_iam_policy" "xray" {
  arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

# IAM Policies
data "template_file" "s3-policy" {
  template = file("files/iam/s3-policy.json.tpl")
  vars     = {
    bucket_arn = aws_s3_bucket.main.arn
  }
}

data "template_file" "cloudwatch-policy" {
  template = file("files/iam/cloudwatch-policy.json.tpl")
}

data "template_file" "sqs-policy" {
  template = file("files/iam/sqs-policy.json.tpl")
  vars     = {
    sqs_queue_arn = aws_sqs_queue.main.arn
  }
}

data "template_file" "dynamodb-policy" {
  template = file("files/iam/dynamodb-policy.json.tpl")
  vars     = {
    dynamodb_table_arn = aws_dynamodb_table.main.arn
  }
}

data "template_file" "nas-policy" {
  template = file("files/iam/nas-policy.json.tpl")
  vars     = {
    bucket_arn = aws_s3_bucket.main.arn
  }
}

# Lambda ZIP file
data "archive_file" "main" {
  type        = "zip"
  source_dir  = "${path.module}/files/lambda"
  output_path = "${path.module}/files/s3-storage.zip"
}
