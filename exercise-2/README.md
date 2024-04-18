# S3 Backup Solution

## Exercise 2 Specification

We have an application that stores data on a filesystem, and our backup policy requires that it stores backups for 180 days and no more. You have selected S3 as the backup storage in a different account.

Your goal is to ensure these backups are stored according to best practices. Please implement an S3 bucket with the appropriate configuration you think of as best practices for this task. Recommended ways to approach the problem are security, cost considerations.

Actually uploading the files as a cron job or something is not part of this exercise, but you have to ensure that the following IAM role is able to upload files into the bucket `arn:aws:iam::123456789012:role/backup_uploader` (it's a fake :) ).

## Task Description and Implementation Overview

This Terraform configuration sets up an Amazon S3 bucket designed to handle backup storage for an application. The backups are retained for exactly 180 days, adhering to the specified backup policy. The S3 bucket is configured with several features to optimize for security and cost:

### Design Decisions

- **Security**: The bucket is set to private with ACLs to restrict access. It includes server-side encryption (AES256) to protect data at rest and utilizes an IAM policy that strictly allows an IAM role to upload files.
- **Lifecycle Management**: Configures automatic deletion of objects after 180 days to manage storage costs effectively and comply with the backup retention policy.
- **Versioning**: Enabled to protect against unintended deletions and overwrites.
- **Module encapsulation with parameters**: For reusability and maintainability.

## Project Structure

```
terraform-aws/
├── example_usage.tf
├── modules/
│   └── s3_backup/
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── variables.tf
├── providers.tf
├── terraform.tfvars
└── variables.tf
```

## Example Usage

This example illustrates how to deploy the S3 backup module with necessary parameters such as region, credentials, bucket name, retention period, and IAM role ARN for upload permissions.

```hcl
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
```

