module "network" {
  source           = "./modules/network"
  project_name     = "example"                     # The name to assign to the project resources
  cidr_block       = "10.10.0.0/16"                # The CIDR block for the VPC
  starting_address = "10.10.10.0"                  # The starting IP address for the first subnet
  subnet_size      = "24"                          # The CIDR prefix size for each subnet
  subnet_count     = 2                             # The number of subnets to create for both Public and Private types
  aws_region       = "us-east-1"                   # AWS region
  azs              = ["us-east-1a", "us-east-1b"]  # A list of AZ-s in the region to spread subnets in
  aws_access_key   = var.main_aws_access_key
  aws_secret_key   = var.main_aws_secret_key
}
