provider "aws" {
  region = "us-east-1"
  # AWS 'access_key' and 'secret_key' credentials are provided through environment variables:
  # export AWS_ACCESS_KEY_ID="your_access_key_id"
  # export AWS_SECRET_ACCESS_KEY="your_secret_key_value"
}

resource "aws_s3_bucket" "backup" {
  bucket = "company-backup-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = "expire_backups"
    status = "Enabled"

    expiration {
      days = 180
    }

    noncurrent_version_expiration {
      noncurrent_days = 180
    }
  }
}

data "aws_iam_policy_document" "backup_policy" {
  statement {
    actions   = ["s3:PutObject", "s3:PutObjectAcl"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::company-backup-bucket/*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:role/backup_uploader"]
    }
  }
}

resource "aws_s3_bucket_policy" "backup" {
  bucket = aws_s3_bucket.backup.id
  policy = data.aws_iam_policy_document.backup_policy.json
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.backup.bucket
  description = "The name of the created S3 bucket for backups."
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.backup.arn
  description = "The ARN of the created S3 bucket for backups."
}

