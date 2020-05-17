#---------------------------------------------------------------------------------------------------
# Retrieving current AWS account metadata
#---------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {
}

#---------------------------------------------------------------------------------------------------
# Retrieving AWS KMS managed key
#---------------------------------------------------------------------------------------------------
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

#---------------------------------------------------------------------------------------------------
# Create JSON policy for 'lambda' 
#---------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

#---------------------------------------------------------------------------------------------------
# Retrieving AWS default policies
#---------------------------------------------------------------------------------------------------
data "aws_iam_policy" "xray" {
  arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

#---------------------------------------------------------------------------------------------------
# Create custom policies
#---------------------------------------------------------------------------------------------------
data "template_file" "s3-policy" {
  template = file("files/iam/s3-policy.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.main.arn
  }
}

data "template_file" "cloudwatch-policy" {
  template = file("files/iam/cloudwatch-policy.json.tpl")
}

data "template_file" "sqs-policy" {
  template = file("files/iam/sqs-policy.json.tpl")
  vars = {
    sqs_queue_arn = aws_sqs_queue.main.arn
  }
}

data "template_file" "dynamodb-policy" {
  template = file("files/iam/dynamodb-policy.json.tpl")
  vars = {
    dynamodb_table_arn = aws_dynamodb_table.main.arn
  }
}

data "template_file" "nas-policy" {
  template = file("files/iam/nas-policy.json.tpl")
  vars = {
    bucket_arn = aws_s3_bucket.main.arn
  }
}

#---------------------------------------------------------------------------------------------------
# Lambda
#---------------------------------------------------------------------------------------------------
data "archive_file" "main" {
  type        = "zip"
  source_dir  = "${path.module}/files/lambda"
  output_path = "${path.module}/files/s3-storage.zip"
}
