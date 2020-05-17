#---------------------------------------------------------------------------------------------------
# DynamoDB
#---------------------------------------------------------------------------------------------------
resource "aws_dynamodb_table" "main" {
  name           = local.dynamodb_name
  billing_mode   = "PROVISIONED"
  read_capacity  = "1"
  write_capacity = "1"

  hash_key = "Id"
  #range_key      = ""

  #server_side_encryption {
  #  enabled = true
  #}

  attribute {
    name = "Id"
    type = "S"
  }

  tags = merge(var.tags, map("Name", local.dynamodb_name))
}
