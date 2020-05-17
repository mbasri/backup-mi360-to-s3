#---------------------------------------------------------------------------------------------------
# Lambda
#---------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "main" {
  filename         = "${path.module}/files/s3-storage.zip"
  description      = "Lambda used to store Mi Home 360 video"
  function_name    = local.lambda_name
  role             = aws_iam_role.lambda.arn
  handler          = "s3-storage.handler"
  source_code_hash = data.archive_file.main.output_base64sha256
  runtime          = "python3.7"
  kms_key_arn      = data.aws_kms_alias.lambda.target_key_arn
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
  tags = merge(var.tags, map("Name", local.lambda_name))
}

# Run Lambda function for each SQS message
resource "aws_lambda_event_source_mapping" "sqs-to-lambda" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = aws_lambda_function.main.arn
}
