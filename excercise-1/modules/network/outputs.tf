output "network_vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "network_public_subnet_ids" {
  value       = module.subnets.public_subnet_ids
  description = "List of IDs of public subnets"
}

output "network_private_subnet_ids" {
  value       = module.subnets.private_subnet_ids
  description = "List of IDs of private subnets"
}

output "network_internet_gateway_id" {
  value       = module.internet_gateway.igw_id
  description = "The ID of the Internet Gateway"
}

