variable "project_name" {
  type        = string
  description = "The name to assign to the project resources"
  default     = "example"
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "A list of availability zones in the region"
  default     = ["us-east-1a", "us-east-1b"]
}

