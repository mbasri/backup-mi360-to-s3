#---------------------------------------------------------------------------------------------------
# AWS provider initialization
#---------------------------------------------------------------------------------------------------
provider "aws" {
  region  = var.region
  version = "~> 2.33.0"
}

#---------------------------------------------------------------------------------------------------
# Terraform remote backend initialization
#---------------------------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "TODO"
    key    = "backup-mi360-to-s3/terraform.tfstate"
    region = "eu-west-3"
  }
}

#---------------------------------------------------------------------------------------------------
# Variables
#---------------------------------------------------------------------------------------------------
locals {
  prefix_name = join("-",
    [
      lower(substr(trimspace(var.tags["Organisation"]), 0, 3)),
      lower(substr(trimspace(var.tags["OrganisationUnit"]), 0, 3)),
      lower(substr(trimspace(var.tags["Application"]), 0, 3)),
      lower(substr(trimspace(var.tags["Environment"]), 0, 3))
    ]
  )

  region = "eu-west-3"

  bucket_name   = local.prefix_name
  lambda_name   = local.prefix_name
  dynamodb_name = local.prefix_name
  sqs_name      = local.prefix_name
}
