#############################
# S3 bucket module
#############################

# Create a secure S3 bucket with versioning and encryption enabled.
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  # Use private ACL to block public access by default.
  acl    = "private"

  # Enable object versioning to improve durability and allow rollbacks.
  versioning {
    enabled = var.enable_versioning
  }

  # Use default encryption at rest for compliance.
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        # Using the default AWS-managed KMS key keeps the example simple.
      }
    }
  }

  tags = merge(var.common_tags, {
    "Name" = var.bucket_name
  })
}

# Optionally enable access logging to a separate bucket.
resource "aws_s3_bucket_logging" "this" {
  count         = var.enable_access_logging ? 1 : 0
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.logging_bucket_id
  target_prefix = var.logging_prefix
}

# Block public access at the bucket level to enforce least privilege.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional lifecycle rule to transition old versions to cheaper storage for cost optimization.
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.enable_lifecycle_rules ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "transition-old-versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 180
      storage_class   = "GLACIER_IR"
    }
  }
}
