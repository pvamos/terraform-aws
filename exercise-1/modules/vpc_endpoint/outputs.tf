output "vpc_endpoint_s3_id" {
  value = aws_vpc_endpoint.s3.id
  description = "The ID of the VPC Endpoint for S3"
}

