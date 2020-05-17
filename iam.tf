resource "aws_iam_role" "lambda" {
  name               = join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "pub"])
  description        = "IAM roles for lambda used by the Bastion"
  assume_role_policy = file("files/iam/lambda-role.json")
  tags = merge(var.tags, map("Name", join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "pub"])))
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "pub", "log"])
  role   = aws_iam_role.lambda.id
  policy = data.template_file.cloudwatch-policy.rendered
}

resource "aws_iam_role_policy" "s3" {
  name   = join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "pub", "bs3"])
  role   = aws_iam_role.lambda.id
  policy = data.template_file.s3-policy.rendered
}

resource "aws_iam_role_policy" "sqs" {
  name   = join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "pub", "sqs"])
  role   = aws_iam_role.lambda.id
  policy = data.template_file.sqs-policy.rendered
}

resource "aws_iam_role_policy" "dynamodb" {
  name   = join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "pub", "dyn"])
  role   = aws_iam_role.lambda.id
  policy = data.template_file.dynamodb-policy.rendered
}

resource "aws_iam_role_policy_attachment" "xray" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${data.aws_iam_policy.xray.arn}"
}

resource "aws_iam_policy" "nas" {
  name   = join("-",[var.name["Organisation"], var.name["OrganisationUnit"], var.name["Application"], var.name["Environment"], "pub", "nas"])
  policy = data.template_file.nas-policy.rendered
}
