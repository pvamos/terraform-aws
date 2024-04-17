module "example_vpcs" {
  source = "./modules/create_vpcs"
  project_name = "example"
  cidr_block = "10.0.0.0/16"
  azs = ["us-east-1a", "us-east-1b"]
}

