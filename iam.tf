resource "aws_iam_role" "lambda" {
  name               = local.prefix_name
  description        = "IAM roles for lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda-role.json
  tags               = merge(var.tags, map("Name", local.prefix_name))
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "${local.prefix_name}-cwl"
  role   = aws_iam_role.lambda.id
  policy = data.template_file.cloudwatch-policy.rendered
}

resource "aws_iam_role_policy" "s3" {
  name   = "${local.prefix_name}-cwl"
  role   = aws_iam_role.lambda.id
  policy = data.template_file.s3-policy.rendered
}

resource "aws_iam_role_policy" "sqs" {
  name   = "${local.prefix_name}-sqs"
  role   = aws_iam_role.lambda.id
  policy = data.template_file.sqs-policy.rendered
}

resource "aws_iam_role_policy" "dynamodb" {
  name   = "${local.prefix_name}-ddb"
  role   = aws_iam_role.lambda.id
  policy = data.template_file.dynamodb-policy.rendered
}

resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.lambda.name
  policy_arn = data.aws_iam_policy.xray.arn
}

resource "aws_iam_policy" "nas" {
  name   = local.prefix_name
  policy = data.template_file.nas-policy.rendered
}
