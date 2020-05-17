# Creation of the bucket
resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name
  region = var.region
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = data.aws_kms_alias.s3.arn
      }
    }
  }
  lifecycle_rule {
    id      = "upload-to-deep-archive-directly"
    enabled = true
    transition {
      days          = 0
      storage_class = "DEEP_ARCHIVE"
    }
    expiration {
      days = 180
    }
  }

  tags = merge(var.tags, map("Name", local.bucket_name))
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
