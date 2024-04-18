module "s3_backup" {
  source                   = "./modules/s3_backup"
  aws_region               = "us-east-1"              # AWS region for the S3 bucket
  aws_access_key           = var.main_aws_access_key
  aws_secret_key           = var.main_aws_secret_key
  bucket_name              = "company-backup-bucket"  # Names the S3 bucket
  retention_days           = 180                      # Sets retention policy for backups
    # IAM role ARN allowed to upload files:
  backup_uploader_role_arn = "arn:aws:iam::123456789012:role/backup_uploader"
}

