variable "project_name" {
  type        = string
  description = "The name to assign to the project resources"
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "starting_address" {
  type        = string
  description = "The starting IP address for the first subnet"
}

variable "subnet_size" {
  type        = string
  description = "The CIDR prefix size for each subnet"
}

variable "subnet_count" {
  type        = number
  description = "The number of subnets to create for both Public and Private types"
}

variable "azs" {
  type        = list(string)
  description = "A list of availability zones in the region"
}

variable "region" {
  type        = string
  description = "AWS region"
}

