output "bucket_name" {
  value       = aws_s3_bucket.main.arn
  description = "Bucket name of the project"
}

output "lambda_arn" {
    value       = aws_lambda_function.main.arn
    description = "Lambda ARN"
}

output "sqs_url" {
    value       = aws_sqs_queue.main.id
    description = "SQS URL"
}

output "api_path" {
  value       = aws_api_gateway_resource.root.path
  description = "API path to call the lambda"
}
