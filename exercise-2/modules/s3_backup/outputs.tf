output "s3_bucket_name" {
  value       = aws_s3_bucket.backup.bucket
  description = "The name of the created S3 bucket for backups."
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.backup.arn
  description = "The ARN of the created S3 bucket for backups."
}

