variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the endpoint will be created"
}

variable "vpc_region" {
  type        = string
  description = "The AWS region where the VPC is located"
}

variable "route_table_ids" {
  type        = list(string)
  description = "List of route table IDs to associate with the VPC Endpoint"
}

