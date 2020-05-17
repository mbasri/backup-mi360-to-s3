provider "aws" {
  region  = var.region
  version = "~> 2.33.0"
}

terraform {
  backend "s3" {
    bucket = "TODO"
    key    = "backup-mi360-to-s3/terraform.tfstate"
    region = "eu-west-3"
  }
}
