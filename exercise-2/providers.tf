# Sets up the AWS provider with credentials and region specified in variables.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.main_aws_region
  access_key = var.main_aws_access_key
  secret_key = var.main_aws_secret_key
}

