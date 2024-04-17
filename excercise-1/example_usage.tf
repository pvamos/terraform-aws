module "network" {
  source         = "./modules/network"
  project_name   = "example"
  cidr_block     = "10.10.0.0/16"
  starting_address = "10.10.10.0"
  subnet_size    = "24"
  subnet_count   = 2
  aws_region     = "us-east-1"
  azs            = ["us-east-1a", "us-east-1b"]
  aws_access_key = var.main_aws_access_key
  aws_secret_key = var.main_aws_secret_key
}

