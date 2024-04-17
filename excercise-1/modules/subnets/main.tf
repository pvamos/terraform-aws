locals {
  ip_parts = split(".", var.starting_address)
  starting_ip_int = sum([
    tonumber(element(local.ip_parts, 0)) * pow(256, 3),
    tonumber(element(local.ip_parts, 1)) * pow(256, 2),
    tonumber(element(local.ip_parts, 2)) * pow(256, 1),
    tonumber(element(local.ip_parts, 3)) * pow(256, 0)
  ])

  base_ip_parts = split(".", cidrhost(var.cidr_block, 0))
  base_ip_int = sum([
    tonumber(element(local.base_ip_parts, 0)) * pow(256, 3),
    tonumber(element(local.base_ip_parts, 1)) * pow(256, 2),
    tonumber(element(local.base_ip_parts, 2)) * pow(256, 1),
    tonumber(element(local.base_ip_parts, 3)) * pow(256, 0)
  ])

  subnet_base_int = pow(2, (32 - tonumber(var.subnet_size)))
  subnet_index_offset = (local.starting_ip_int - local.base_ip_int) / local.subnet_base_int
  newbits = tonumber(var.subnet_size) - 16  # Adjust according to your VPC CIDR block
}

# Public Subnets
resource "aws_subnet" "public" {
  count = var.subnet_count
  vpc_id = var.vpc_id

  cidr_block = cidrsubnet(var.cidr_block, local.newbits, floor(local.subnet_index_offset) + count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-${count.index}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count = var.subnet_count
  vpc_id = var.vpc_id

  cidr_block = cidrsubnet(var.cidr_block, local.newbits, floor(local.subnet_index_offset) + var.subnet_count + count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.project_name}-private-${count.index}"
  }
}

