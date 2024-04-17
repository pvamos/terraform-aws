variable "project_name" {
  type    = string
  description = "The name to assign to the project resources"
}

variable "cidr_block" {
  type    = string
  description = "The CIDR block for the VPC"
}

variable "azs" {
  type    = list(string)
  description = "A list of availability zones in the region"
}
