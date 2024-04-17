# Outputs for subnet IDs
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
  description = "List of IDs of public subnets"
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
  description = "List of IDs of private subnets"
}

