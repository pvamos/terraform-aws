# Output VPC ID for further usage in other modules
output "vpc_id" {
  value = aws_vpc.main.id
  description = "The ID of the VPC"
}

