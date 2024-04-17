# This module acts as a wrapper that encapsulates the VPC, subnets, internet gateway, and other components.

module "vpc" {
  source       = "../vpc"
  project_name = var.project_name
  cidr_block   = var.cidr_block
}

module "subnets" {
  source           = "../subnets"
  vpc_id           = module.vpc.vpc_id
  cidr_block       = var.cidr_block  # Pass the whole VPC CIDR block
  starting_address = var.starting_address
  subnet_size      = var.subnet_size
  subnet_count     = var.subnet_count
  azs              = var.azs
  project_name     = var.project_name
}

module "internet_gateway" {
  source       = "../internet_gateway"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

module "nat_gateway" {
  source           = "../nat_gateway"
  public_subnet_id = module.subnets.public_subnet_ids[0]
}

module "route_tables" {
  source              = "../route_tables"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.igw_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids
}

module "vpc_endpoint" {
  source          = "../vpc_endpoint"
  vpc_id          = module.vpc.vpc_id
  region          = var.region
  route_table_ids = [module.route_tables.private_route_table_id]
}

