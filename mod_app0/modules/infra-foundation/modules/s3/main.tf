#############################################################################
# S3 Bucket for Athena
#############################################################################

# bucket athena
resource "aws_s3_bucket" "athena_results" {
  bucket        = "${var.organization_name}-${var.environment}-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}-athena"
  force_destroy = "true"
  tags          = var.common_tags
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket                  = aws_s3_bucket.athena_results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    id     = "foundations-lifecycle-rule"
    status = "Enabled"

    filter {
      prefix = "/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 60
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }



}
 