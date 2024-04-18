# To align with backup best practices:
#   Security through encryption, access control, and lifecycle management.

resource "aws_s3_bucket" "backup" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "backup" {
  bucket = aws_s3_bucket.backup.id
  acl    = "private"
}

# Versioning enabled to protect against unintended deletions and overwrites.
resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id
  rule {
    id     = "expire_backups"
    status = "Enabled"
    expiration {
      days = var.retention_days
    }
    noncurrent_version_expiration {
      noncurrent_days = var.retention_days
    }
  }
}

# configures server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM policies to allow access
data "aws_iam_policy_document" "backup_policy" {
  statement {
    actions   = ["s3:PutObject", "s3:PutObjectAcl"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    principals {
      type        = "AWS"
      identifiers = [var.backup_uploader_role_arn]
    }
  }
}

# Apply IAM policies to S3 bucket
resource "aws_s3_bucket_policy" "backup" {
  bucket = aws_s3_bucket.backup.id
  policy = data.aws_iam_policy_document.backup_policy.json
}
