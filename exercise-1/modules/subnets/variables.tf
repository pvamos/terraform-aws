variable "vpc_id" {
  type = string
  description = "The VPC ID where subnets will be created"
}

variable "cidr_block" {
  type = string
  description = "The CIDR block for the entire VPC"
}

variable "starting_address" {
  type = string
  description = "The starting IP address for the first subnet"
}

variable "subnet_size" {
  type = string
  description = "The CIDR prefix size for each subnet"
}

variable "subnet_count" {
  type = number
  description = "The number of subnets to create for both Public and Private types"
}

variable "azs" {
  type = list(string)
  description = "A list of availability zones in the region"
}

variable "project_name" {
  type = string
  description = "The name to assign to the project resources"
}

