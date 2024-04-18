locals {
  # Split the starting IP address into its individual components (parts of the dotted IP address).
  ip_parts = split(".", var.starting_address)
  
  # Convert the dotted IP address into an integer value. This is achieved by converting each part of the IP address
  # from string to number, and multiplying each part by 256 raised to the power of its position in the IP address.
  starting_ip_int = sum([
    tonumber(element(local.ip_parts, 0)) * pow(256, 3),  # Convert the first part and multiply by 256^3
    tonumber(element(local.ip_parts, 1)) * pow(256, 2),  # Convert the second part and multiply by 256^2
    tonumber(element(local.ip_parts, 2)) * pow(256, 1),  # Convert the third part and multiply by 256^1
    tonumber(element(local.ip_parts, 3)) * pow(256, 0)   # Convert the fourth part
  ])

  # Split the CIDR block's base IP (i.e., the first IP in the CIDR block) into parts.
  base_ip_parts = split(".", cidrhost(var.cidr_block, 0))
  
  # Convert the base IP address of the CIDR block into an integer format similar to starting_ip_int.
  base_ip_int = sum([
    tonumber(element(local.base_ip_parts, 0)) * pow(256, 3),
    tonumber(element(local.base_ip_parts, 1)) * pow(256, 2),
    tonumber(element(local.base_ip_parts, 2)) * pow(256, 1),
    tonumber(element(local.base_ip_parts, 3)) * pow(256, 0)
  ])

  # Calculate the base integer value for a subnet based on the subnet size. This is done by
  # calculating 2 raised to the power of (32 - subnet size).
  subnet_base_int = pow(2, (32 - tonumber(var.subnet_size)))
  
  # Calculate the offset for the subnet index by finding the difference between the starting IP integer and
  # the base IP integer, then dividing by the number of IPs per subnet.
  subnet_index_offset = (local.starting_ip_int - local.base_ip_int) / local.subnet_base_int
  
  # Calculate the number of additional subnet bits needed over the base 16 bits provided by the VPC CIDR block.
  newbits = tonumber(var.subnet_size) - 16  # Adjust according to your VPC CIDR block
}

# Public Subnets definition
resource "aws_subnet" "public" {
  count = var.subnet_count  # Number of public subnets to create
  vpc_id = var.vpc_id       # VPC ID where the subnets will be created

  # Calculate the CIDR block for each public subnet. It adjusts the CIDR block based on the subnet index offset
  # and the loop index, which allows each subnet to have a unique range within the VPC CIDR block.
  cidr_block = cidrsubnet(var.cidr_block, local.newbits, floor(local.subnet_index_offset) + count.index)

  availability_zone = element(var.azs, count.index)  # Assign the subnet to an AZ based on the index

  map_public_ip_on_launch = true  # Enable automatic public IP assignment for instances launched in this subnet

  tags = {
    Name = "${var.project_name}-public-${count.index}"  # Tag with a unique name using the project name and index
  }
}

# Private Subnets definition
resource "aws_subnet" "private" {
  count = var.subnet_count  # Number of private subnets to create
  vpc_id = var.vpc_id       # VPC ID where the subnets will be created

  # Calculate the CIDR block for each private subnet, similar to public subnets but with an additional offset
  # to avoid overlap with public subnet IP ranges.
  cidr_block = cidrsubnet(var.cidr_block, local.newbits, floor(local.subnet_index_offset) + var.subnet_count + count.index)

  availability_zone = element(var.azs, count.index)  # Assign the subnet to an AZ based on the index

  tags = {
    Name = "${var.project_name}-private-${count.index}"  # Tag with a unique name using the project name and index
  }
}

