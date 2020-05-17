#---------------------------------------------------------------------------------------------------
# SQS
#---------------------------------------------------------------------------------------------------
resource "aws_sqs_queue" "main" {
  name = local.sqs_name
  #kms_master_key_id           = data.aws_kms_alias.lambda.arn
  max_message_size           = 2048
  visibility_timeout_seconds = 20
  message_retention_seconds  = 300
  policy                     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:${local.sqs_name}",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.main.arn}" }
      }
    }
  ]
}
POLICY
  tags                       = merge(var.tags, map("Name", local.sqs_name))
}

# Send a SQS message when a file is uploaded
resource "aws_s3_bucket_notification" "sqs" {
  bucket = aws_s3_bucket.main.id
  queue {
    id            = "upload-video"
    queue_arn     = aws_sqs_queue.main.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "upload/"
    filter_suffix = ".mp4"
  }
}
