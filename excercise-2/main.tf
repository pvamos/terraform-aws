
resource "aws_s3_bucket" "backup" {
  bucket = "company-backup-bucket"
}

resource "aws_s3_bucket_acl" "backup" {
  bucket = aws_s3_bucket.backup.id
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

resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
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
