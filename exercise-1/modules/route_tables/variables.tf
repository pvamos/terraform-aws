variable "vpc_id" {
  type        = string
  description = "ID of the VPC to which the route tables belong"
}

variable "internet_gateway_id" {
  type        = string
  description = "ID of the Internet Gateway"
}

variable "nat_gateway_id" {
  type        = string
  description = "ID of the NAT Gateway used in private route tables"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for associating with the public route table"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for associating with the private route table"
}

