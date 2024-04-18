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
exercise-2/
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

## Example Output

Tested with:

```
$ terraform --version
Terraform v1.8.0
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v5.45.0

$ uname -a
Linux l440.peter.local 6.8.5-201.fc39.x86_64 #1 SMP PREEMPT_DYNAMIC Thu Apr 11 18:25:26 UTC 2024 x86_64 GNU/Linux

$ cat /etc/fedora-release
Fedora release 39 (Thirty Nine)
```

### Terraform init
```
p@l440:~/terraform-aws/exercise-2$ terraform init

Initializing the backend...
Initializing modules...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.45.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Terraform plan
```
p@l440:~/terraform-aws/exercise-2$ terraform plan
module.s3_backup.data.aws_iam_policy_document.backup_policy: Reading...
module.s3_backup.data.aws_iam_policy_document.backup_policy: Read complete after 0s [id=3352074433]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.s3_backup.aws_s3_bucket.backup will be created
  + resource "aws_s3_bucket" "backup" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "company-backup-bucket"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags_all                    = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
    }

  # module.s3_backup.aws_s3_bucket_acl.backup will be created
  + resource "aws_s3_bucket_acl" "backup" {
      + acl    = "private"
      + bucket = (known after apply)
      + id     = (known after apply)
    }

  # module.s3_backup.aws_s3_bucket_lifecycle_configuration.backup will be created
  + resource "aws_s3_bucket_lifecycle_configuration" "backup" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + id     = "expire_backups"
          + status = "Enabled"

          + expiration {
              + days                         = 180
              + expired_object_delete_marker = (known after apply)
            }

          + noncurrent_version_expiration {
              + noncurrent_days = 180
            }
        }
    }

  # module.s3_backup.aws_s3_bucket_policy.backup will be created
  + resource "aws_s3_bucket_policy" "backup" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + policy = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = [
                          + "s3:PutObjectAcl",
                          + "s3:PutObject",
                        ]
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::123456789012:role/backup_uploader"
                        }
                      + Resource  = "arn:aws:s3:::company-backup-bucket/*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
    }

  # module.s3_backup.aws_s3_bucket_server_side_encryption_configuration.backup will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + apply_server_side_encryption_by_default {
              + sse_algorithm     = "AES256"
                # (1 unchanged attribute hidden)
            }
        }
    }

  # module.s3_backup.aws_s3_bucket_versioning.backup will be created
  + resource "aws_s3_bucket_versioning" "backup" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

Plan: 6 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
p@l440:~/terraform-aws/exercise-2$
```
