variable "aws_access_key" {
  type = string
  description = "AWS access_key parameter"
}

variable "aws_secret_key" {
  type = string
  description = "AWS secret_key parameter"
}

variable "project_name" {
  type        = string
  description = "The name to assign to the project resources"
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "A list of availability zones in the region"
}

