variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to be created."
}

variable "retention_days" {
  type        = number
  description = "Number of days to retain backups in the bucket."
}

variable "backup_uploader_role_arn" {
  type        = string
  description = "ARN of the IAM role allowed to upload files."
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_access_key" {
  type = string
  description = "AWS provider access_key parameter"
}

variable "aws_secret_key" {
  type = string
  description = "AWS provider secret_key parameter"
}

