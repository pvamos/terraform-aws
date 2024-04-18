# Terraform AWS Network Module

## Exercise 1 Specification

Create a terraform module that does the following:

  - Deploys a VPC with internet access
  - 4 subnets across 2 AZs
    - 2 Public subnets, designed to host a load balancer or reverse proxy
      - Can communicate directly with the internet
    - 2 private designed to host application servers
      - internet access for outbound connections.

Ensure that calls to the S3 API from within the VPC does not leave the AWS backbone network for security and cost reduction.

Create an example where you use the module.

No need to actually deploy this, code is enough! Some resources required here are not included within the free tier, do not spend money! The main goal is that the terraform plan runs successfully.

## Task Description

- This Terraform module sets up a Virtual Private Cloud (VPC) within AWS, together with Private and Public subnets.
- It organizes subnets over availability zones.
- The same specified number of subnets are created for Private and Public use.
- Public subnets are connected to the internet through an Internet Gateway
- Private subnets use a NAT Gateway configured in one of the public subnets for outbound internet access.
- The module also includes a VPC endpoint for S3 to ensure that S3 API calls are routed internally within AWS, improving security and reducing costs.

## Flexibility

As IP subnet calculation is done by converting addresses to integer value first, the code is able to handle flexible number and size of subnets. For example:

- If `subnet_count = 2` and `subnet_size = 24`, then creates `2` consecutive `/24` subnets starting at `starting_address` for Public, then (without a gap) assigns `2` consecutive `/24` subnets for Private.

- If `subnet_count = 3` and `subnet_size = 26`, then creates `3` consecutive `/26` subnets starting at `starting_address` for Public, then (without a gap) assigns `3` consecutive `/26` subnets for Private.

## Project Structure

The main module to invoke is `network`, it is using other reusable modules for subtasks:
- `internet_gateway`
- `nat_gateway`
- `route_tables`
- `subnets`
- `vpc`
- `vpc_endpoint`

```
exercise-1/
├── example_usage.tf
├── modules
│   ├── internet_gateway
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── nat_gateway
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   ├── route_tables
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── subnets
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── vpc
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── vpc_endpoint
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── terraform.tfvars
└── variables.tf
```

## Example Usage

```hcl
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
```

## Improvement Possibilities

- Use AWS Secrets Manager or Hashicorp Vault to store/manage AWS credentials
- Check if the provided VPC CIDR block and subnet sizes and numbers are valid
- Check if the subnets all fit into the VPC CIDR block specified.

## Example Output

Tested with:

```
$ terraform --version
Terraform v1.8.0
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v5.45.0

$ uname -a
Linux l440.peter.local 6.8.5-201.fc39.x86_64 #1 SMP PREEMPT_DYNAMIC Thu Apr 11 18:25:26 UTC 2024 x86_64 GNU/Linux

$ cat /etc/fedora-release
Fedora release 39 (Thirty Nine)
```

### Terraform init
```
p@l440:~/terraform-aws/exercise-1$ terraform init

Initializing the backend...
Initializing modules...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.45.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Terraform plan
```
p@l440:~/terraform-aws/exercise-1$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.network.module.internet_gateway.aws_internet_gateway.gw will be created
  + resource "aws_internet_gateway" "gw" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "example-igw"
        }
      + tags_all = {
          + "Name" = "example-igw"
        }
      + vpc_id   = (known after apply)
    }

  # module.network.module.nat_gateway.aws_eip.nat will be created
  + resource "aws_eip" "nat" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = "vpc"
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags_all             = (known after apply)
      + vpc                  = (known after apply)
    }

  # module.network.module.nat_gateway.aws_nat_gateway.nat will be created
  + resource "aws_nat_gateway" "nat" {
      + allocation_id                      = (known after apply)
      + association_id                     = (known after apply)
      + connectivity_type                  = "public"
      + id                                 = (known after apply)
      + network_interface_id               = (known after apply)
      + private_ip                         = (known after apply)
      + public_ip                          = (known after apply)
      + secondary_private_ip_address_count = (known after apply)
      + secondary_private_ip_addresses     = (known after apply)
      + subnet_id                          = (known after apply)
      + tags_all                           = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table.private will be created
  + resource "aws_route_table" "private" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + nat_gateway_id             = (known after apply)
                # (11 unchanged attributes hidden)
            },
        ]
      + tags_all         = (known after apply)
      + vpc_id           = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table.public will be created
  + resource "aws_route_table" "public" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + gateway_id                 = (known after apply)
                # (11 unchanged attributes hidden)
            },
        ]
      + tags_all         = (known after apply)
      + vpc_id           = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table_association.private[0] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table_association.private[1] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table_association.public[0] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table_association.public[1] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.module.subnets.aws_subnet.private[0] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.10.12.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "example-private-0"
        }
      + tags_all                                       = {
          + "Name" = "example-private-0"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.module.subnets.aws_subnet.private[1] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.10.13.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "example-private-1"
        }
      + tags_all                                       = {
          + "Name" = "example-private-1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.module.subnets.aws_subnet.public[0] will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.10.10.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "example-public-0"
        }
      + tags_all                                       = {
          + "Name" = "example-public-0"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.module.subnets.aws_subnet.public[1] will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.10.11.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "example-public-1"
        }
      + tags_all                                       = {
          + "Name" = "example-public-1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.module.vpc.aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.10.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "example-vpc"
        }
      + tags_all                             = {
          + "Name" = "example-vpc"
        }
    }

  # module.network.module.vpc_endpoint.aws_vpc_endpoint.s3 will be created
  + resource "aws_vpc_endpoint" "s3" {
      + arn                   = (known after apply)
      + cidr_blocks           = (known after apply)
      + dns_entry             = (known after apply)
      + id                    = (known after apply)
      + ip_address_type       = (known after apply)
      + network_interface_ids = (known after apply)
      + owner_id              = (known after apply)
      + policy                = (known after apply)
      + prefix_list_id        = (known after apply)
      + private_dns_enabled   = false
      + requester_managed     = (known after apply)
      + route_table_ids       = (known after apply)
      + security_group_ids    = (known after apply)
      + service_name          = "com.amazonaws.us-east-1.s3"
      + state                 = (known after apply)
      + subnet_ids            = (known after apply)
      + tags_all              = (known after apply)
      + vpc_endpoint_type     = "Gateway"
      + vpc_id                = (known after apply)
    }

Plan: 15 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

### Terraform apply
```
p@l440:~/terraform-aws/exercise-1$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.network.module.internet_gateway.aws_internet_gateway.gw will be created
  + resource "aws_internet_gateway" "gw" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "example-igw"
        }
      + tags_all = {
          + "Name" = "example-igw"
        }
      + vpc_id   = (known after apply)
    }

  # module.network.module.nat_gateway.aws_eip.nat will be created
  + resource "aws_eip" "nat" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = "vpc"
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags_all             = (known after apply)
      + vpc                  = (known after apply)
    }

  # module.network.module.nat_gateway.aws_nat_gateway.nat will be created
  + resource "aws_nat_gateway" "nat" {
      + allocation_id                      = (known after apply)
      + association_id                     = (known after apply)
      + connectivity_type                  = "public"
      + id                                 = (known after apply)
      + network_interface_id               = (known after apply)
      + private_ip                         = (known after apply)
      + public_ip                          = (known after apply)
      + secondary_private_ip_address_count = (known after apply)
      + secondary_private_ip_addresses     = (known after apply)
      + subnet_id                          = (known after apply)
      + tags_all                           = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table.private will be created
  + resource "aws_route_table" "private" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + nat_gateway_id             = (known after apply)
                # (11 unchanged attributes hidden)
            },
        ]
      + tags_all         = (known after apply)
      + vpc_id           = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table.public will be created
  + resource "aws_route_table" "public" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + gateway_id                 = (known after apply)
                # (11 unchanged attributes hidden)
            },
        ]
      + tags_all         = (known after apply)
      + vpc_id           = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table_association.private[0] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table_association.private[1] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table_association.public[0] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.module.route_tables.aws_route_table_association.public[1] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.module.subnets.aws_subnet.private[0] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.10.12.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "example-private-0"
        }
      + tags_all                                       = {
          + "Name" = "example-private-0"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.module.subnets.aws_subnet.private[1] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.10.13.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "example-private-1"
        }
      + tags_all                                       = {
          + "Name" = "example-private-1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.module.subnets.aws_subnet.public[0] will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.10.10.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "example-public-0"
        }
      + tags_all                                       = {
          + "Name" = "example-public-0"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.module.subnets.aws_subnet.public[1] will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.10.11.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "example-public-1"
        }
      + tags_all                                       = {
          + "Name" = "example-public-1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.module.vpc.aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.10.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "example-vpc"
        }
      + tags_all                             = {
          + "Name" = "example-vpc"
        }
    }

  # module.network.module.vpc_endpoint.aws_vpc_endpoint.s3 will be created
  + resource "aws_vpc_endpoint" "s3" {
      + arn                   = (known after apply)
      + cidr_blocks           = (known after apply)
      + dns_entry             = (known after apply)
      + id                    = (known after apply)
      + ip_address_type       = (known after apply)
      + network_interface_ids = (known after apply)
      + owner_id              = (known after apply)
      + policy                = (known after apply)
      + prefix_list_id        = (known after apply)
      + private_dns_enabled   = false
      + requester_managed     = (known after apply)
      + route_table_ids       = (known after apply)
      + security_group_ids    = (known after apply)
      + service_name          = "com.amazonaws.us-east-1.s3"
      + state                 = (known after apply)
      + subnet_ids            = (known after apply)
      + tags_all              = (known after apply)
      + vpc_endpoint_type     = "Gateway"
      + vpc_id                = (known after apply)
    }

Plan: 15 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.network.module.nat_gateway.aws_eip.nat: Creating...
module.network.module.vpc.aws_vpc.main: Creating...
module.network.module.nat_gateway.aws_eip.nat: Creation complete after 1s [id=eipalloc-0524bf23721b46672]
module.network.module.vpc.aws_vpc.main: Still creating... [10s elapsed]
module.network.module.vpc.aws_vpc.main: Creation complete after 13s [id=vpc-0269c6e22c190485a]
module.network.module.internet_gateway.aws_internet_gateway.gw: Creating...
module.network.module.subnets.aws_subnet.private[0]: Creating...
module.network.module.subnets.aws_subnet.public[0]: Creating...
module.network.module.subnets.aws_subnet.public[1]: Creating...
module.network.module.subnets.aws_subnet.private[1]: Creating...
module.network.module.internet_gateway.aws_internet_gateway.gw: Creation complete after 1s [id=igw-04741444a78117f46]
module.network.module.route_tables.aws_route_table.public: Creating...
module.network.module.subnets.aws_subnet.private[1]: Creation complete after 1s [id=subnet-00254097f2241969f]
module.network.module.subnets.aws_subnet.private[0]: Creation complete after 1s [id=subnet-026cda4c841d76183]
module.network.module.route_tables.aws_route_table.public: Creation complete after 2s [id=rtb-0d60aac02416a1108]
module.network.module.subnets.aws_subnet.public[1]: Still creating... [10s elapsed]
module.network.module.subnets.aws_subnet.public[0]: Still creating... [10s elapsed]
module.network.module.subnets.aws_subnet.public[0]: Creation complete after 12s [id=subnet-024c40f6cd37e56ad]
module.network.module.subnets.aws_subnet.public[1]: Creation complete after 12s [id=subnet-0a1e8723a85ab9331]
module.network.module.route_tables.aws_route_table_association.public[0]: Creating...
module.network.module.route_tables.aws_route_table_association.public[1]: Creating...
module.network.module.nat_gateway.aws_nat_gateway.nat: Creating...
module.network.module.route_tables.aws_route_table_association.public[0]: Creation complete after 1s [id=rtbassoc-0df28f5b5f2f6b064]
module.network.module.route_tables.aws_route_table_association.public[1]: Creation complete after 1s [id=rtbassoc-0ec7b172e67cf545c]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still creating... [10s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still creating... [20s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still creating... [30s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still creating... [40s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still creating... [50s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still creating... [1m0s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still creating... [1m10s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still creating... [1m20s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still creating... [1m30s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still creating... [1m40s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Creation complete after 1m46s [id=nat-02beee08af1764a16]
module.network.module.route_tables.aws_route_table.private: Creating...
module.network.module.route_tables.aws_route_table.private: Creation complete after 2s [id=rtb-079f013a4d5b6e2cd]
module.network.module.route_tables.aws_route_table_association.private[0]: Creating...
module.network.module.route_tables.aws_route_table_association.private[1]: Creating...
module.network.module.vpc_endpoint.aws_vpc_endpoint.s3: Creating...
module.network.module.route_tables.aws_route_table_association.private[0]: Creation complete after 1s [id=rtbassoc-0de66a8d9a408983c]
module.network.module.route_tables.aws_route_table_association.private[1]: Creation complete after 1s [id=rtbassoc-06abccb9652d10c05]
module.network.module.vpc_endpoint.aws_vpc_endpoint.s3: Creation complete after 7s [id=vpce-08f927858fe08b3d7]

Apply complete! Resources: 15 added, 0 changed, 0 destroyed.
p@l440:~/terraform-aws/exercise-1$

```

### Checking the created objects

AWS credentials are in `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

```
p@l440:~/terraform-aws/exercise-1$ aws ec2 describe-vpcs --region us-east-1 --filters "Name=tag:Name,Values=example-vpc"
{
    "Vpcs": [
        {
            "CidrBlock": "10.10.0.0/16",
            "DhcpOptionsId": "dopt-097221ed8fdf1b4f4",
            "State": "available",
            "VpcId": "vpc-0269c6e22c190485a",
            "OwnerId": "767397961434",
            "InstanceTenancy": "default",
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-00a761b263eb80eaa",
                    "CidrBlock": "10.10.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": false,
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "example-vpc"
                }
            ]
        }
    ]
}


p@l440:~/terraform-aws/exercise-1$ aws ec2 describe-subnets --region us-east-1 --filters "Name=vpc-id,Values=vpc-0269c6e22c190485a"
{
    "Subnets": [
        {
            "AvailabilityZone": "us-east-1b",
            "AvailabilityZoneId": "use1-az1",
            "AvailableIpAddressCount": 251,
            "CidrBlock": "10.10.13.0/24",
            "DefaultForAz": false,
            "MapPublicIpOnLaunch": false,
            "MapCustomerOwnedIpOnLaunch": false,
            "State": "available",
            "SubnetId": "subnet-00254097f2241969f",
            "VpcId": "vpc-0269c6e22c190485a",
            "OwnerId": "767397961434",
            "AssignIpv6AddressOnCreation": false,
            "Ipv6CidrBlockAssociationSet": [],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "example-private-1"
                }
            ],
            "SubnetArn": "arn:aws:ec2:us-east-1:767397961434:subnet/subnet-00254097f2241969f",
            "EnableDns64": false,
            "Ipv6Native": false,
            "PrivateDnsNameOptionsOnLaunch": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            }
        },
        {
            "AvailabilityZone": "us-east-1a",
            "AvailabilityZoneId": "use1-az6",
            "AvailableIpAddressCount": 251,
            "CidrBlock": "10.10.12.0/24",
            "DefaultForAz": false,
            "MapPublicIpOnLaunch": false,
            "MapCustomerOwnedIpOnLaunch": false,
            "State": "available",
            "SubnetId": "subnet-026cda4c841d76183",
            "VpcId": "vpc-0269c6e22c190485a",
            "OwnerId": "767397961434",
            "AssignIpv6AddressOnCreation": false,
            "Ipv6CidrBlockAssociationSet": [],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "example-private-0"
                }
            ],
            "SubnetArn": "arn:aws:ec2:us-east-1:767397961434:subnet/subnet-026cda4c841d76183",
            "EnableDns64": false,
            "Ipv6Native": false,
            "PrivateDnsNameOptionsOnLaunch": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            }
        },
        {
            "AvailabilityZone": "us-east-1b",
            "AvailabilityZoneId": "use1-az1",
            "AvailableIpAddressCount": 251,
            "CidrBlock": "10.10.11.0/24",
            "DefaultForAz": false,
            "MapPublicIpOnLaunch": true,
            "MapCustomerOwnedIpOnLaunch": false,
            "State": "available",
            "SubnetId": "subnet-0a1e8723a85ab9331",
            "VpcId": "vpc-0269c6e22c190485a",
            "OwnerId": "767397961434",
            "AssignIpv6AddressOnCreation": false,
            "Ipv6CidrBlockAssociationSet": [],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "example-public-1"
                }
            ],
            "SubnetArn": "arn:aws:ec2:us-east-1:767397961434:subnet/subnet-0a1e8723a85ab9331",
            "EnableDns64": false,
            "Ipv6Native": false,
            "PrivateDnsNameOptionsOnLaunch": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            }
        },
        {
            "AvailabilityZone": "us-east-1a",
            "AvailabilityZoneId": "use1-az6",
            "AvailableIpAddressCount": 250,
            "CidrBlock": "10.10.10.0/24",
            "DefaultForAz": false,
            "MapPublicIpOnLaunch": true,
            "MapCustomerOwnedIpOnLaunch": false,
            "State": "available",
            "SubnetId": "subnet-024c40f6cd37e56ad",
            "VpcId": "vpc-0269c6e22c190485a",
            "OwnerId": "767397961434",
            "AssignIpv6AddressOnCreation": false,
            "Ipv6CidrBlockAssociationSet": [],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "example-public-0"
                }
            ],
            "SubnetArn": "arn:aws:ec2:us-east-1:767397961434:subnet/subnet-024c40f6cd37e56ad",
            "EnableDns64": false,
            "Ipv6Native": false,
            "PrivateDnsNameOptionsOnLaunch": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            }
        }
    ]
}


p@l440:~/terraform-aws/exercise-1$ aws ec2 describe-internet-gateways --region us-east-1 --filters "Name=attachment.vpc-id,Values=vpc-0269c6e22c190485a"
{
    "InternetGateways": [
        {
            "Attachments": [
                {
                    "State": "available",
                    "VpcId": "vpc-0269c6e22c190485a"
                }
            ],
            "InternetGatewayId": "igw-04741444a78117f46",
            "OwnerId": "767397961434",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "example-igw"
                }
            ]
        }
    ]
}


p@l440:~/terraform-aws/exercise-1$ aws ec2 describe-route-tables --region us-east-1 --filters "Name=vpc-id,Values=vpc-0269c6e22c190485a"
{
    "RouteTables": [
        {
            "Associations": [
                {
                    "Main": false,
                    "RouteTableAssociationId": "rtbassoc-0ec7b172e67cf545c",
                    "RouteTableId": "rtb-0d60aac02416a1108",
                    "SubnetId": "subnet-0a1e8723a85ab9331",
                    "AssociationState": {
                        "State": "associated"
                    }
                },
                {
                    "Main": false,
                    "RouteTableAssociationId": "rtbassoc-0df28f5b5f2f6b064",
                    "RouteTableId": "rtb-0d60aac02416a1108",
                    "SubnetId": "subnet-024c40f6cd37e56ad",
                    "AssociationState": {
                        "State": "associated"
                    }
                }
            ],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-0d60aac02416a1108",
            "Routes": [
                {
                    "DestinationCidrBlock": "10.10.0.0/16",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                },
                {
                    "DestinationCidrBlock": "0.0.0.0/0",
                    "GatewayId": "igw-04741444a78117f46",
                    "Origin": "CreateRoute",
                    "State": "active"
                }
            ],
            "Tags": [],
            "VpcId": "vpc-0269c6e22c190485a",
            "OwnerId": "767397961434"
        },
        {
            "Associations": [
                {
                    "Main": true,
                    "RouteTableAssociationId": "rtbassoc-055f1c7ef677124fa",
                    "RouteTableId": "rtb-0e4992152436e23ba",
                    "AssociationState": {
                        "State": "associated"
                    }
                }
            ],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-0e4992152436e23ba",
            "Routes": [
                {
                    "DestinationCidrBlock": "10.10.0.0/16",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                }
            ],
            "Tags": [],
            "VpcId": "vpc-0269c6e22c190485a",
            "OwnerId": "767397961434"
        },
        {
            "Associations": [
                {
                    "Main": false,
                    "RouteTableAssociationId": "rtbassoc-0de66a8d9a408983c",
                    "RouteTableId": "rtb-079f013a4d5b6e2cd",
                    "SubnetId": "subnet-026cda4c841d76183",
                    "AssociationState": {
                        "State": "associated"
                    }
                },
                {
                    "Main": false,
                    "RouteTableAssociationId": "rtbassoc-06abccb9652d10c05",
                    "RouteTableId": "rtb-079f013a4d5b6e2cd",
                    "SubnetId": "subnet-00254097f2241969f",
                    "AssociationState": {
                        "State": "associated"
                    }
                }
            ],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-079f013a4d5b6e2cd",
            "Routes": [
                {
                    "DestinationCidrBlock": "10.10.0.0/16",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                },
                {
                    "DestinationCidrBlock": "0.0.0.0/0",
                    "NatGatewayId": "nat-02beee08af1764a16",
                    "Origin": "CreateRoute",
                    "State": "active"
                },
                {
                    "DestinationPrefixListId": "pl-63a5400a",
                    "GatewayId": "vpce-08f927858fe08b3d7",
                    "Origin": "CreateRoute",
                    "State": "active"
                }
            ],
            "Tags": [],
            "VpcId": "vpc-0269c6e22c190485a",
            "OwnerId": "767397961434"
        }
    ]
}
```

### Terraform destroy
```
p@l440:~/terraform-aws/exercise-1$ terraform destroy
module.network.module.nat_gateway.aws_eip.nat: Refreshing state... [id=eipalloc-0524bf23721b46672]
module.network.module.vpc.aws_vpc.main: Refreshing state... [id=vpc-0269c6e22c190485a]
module.network.module.internet_gateway.aws_internet_gateway.gw: Refreshing state... [id=igw-04741444a78117f46]
module.network.module.subnets.aws_subnet.public[0]: Refreshing state... [id=subnet-024c40f6cd37e56ad]
module.network.module.subnets.aws_subnet.private[1]: Refreshing state... [id=subnet-00254097f2241969f]
module.network.module.subnets.aws_subnet.public[1]: Refreshing state... [id=subnet-0a1e8723a85ab9331]
module.network.module.subnets.aws_subnet.private[0]: Refreshing state... [id=subnet-026cda4c841d76183]
module.network.module.route_tables.aws_route_table.public: Refreshing state... [id=rtb-0d60aac02416a1108]
module.network.module.route_tables.aws_route_table_association.public[1]: Refreshing state... [id=rtbassoc-0ec7b172e67cf545c]
module.network.module.route_tables.aws_route_table_association.public[0]: Refreshing state... [id=rtbassoc-0df28f5b5f2f6b064]
module.network.module.nat_gateway.aws_nat_gateway.nat: Refreshing state... [id=nat-02beee08af1764a16]
module.network.module.route_tables.aws_route_table.private: Refreshing state... [id=rtb-079f013a4d5b6e2cd]
module.network.module.route_tables.aws_route_table_association.private[1]: Refreshing state... [id=rtbassoc-06abccb9652d10c05]
module.network.module.route_tables.aws_route_table_association.private[0]: Refreshing state... [id=rtbassoc-0de66a8d9a408983c]
module.network.module.vpc_endpoint.aws_vpc_endpoint.s3: Refreshing state... [id=vpce-08f927858fe08b3d7]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # module.network.module.internet_gateway.aws_internet_gateway.gw will be destroyed
  - resource "aws_internet_gateway" "gw" {
      - arn      = "arn:aws:ec2:us-east-1:767397961434:internet-gateway/igw-04741444a78117f46" -> null
      - id       = "igw-04741444a78117f46" -> null
      - owner_id = "767397961434" -> null
      - tags     = {
          - "Name" = "example-igw"
        } -> null
      - tags_all = {
          - "Name" = "example-igw"
        } -> null
      - vpc_id   = "vpc-0269c6e22c190485a" -> null
    }

  # module.network.module.nat_gateway.aws_eip.nat will be destroyed
  - resource "aws_eip" "nat" {
      - allocation_id            = "eipalloc-0524bf23721b46672" -> null
      - association_id           = "eipassoc-0640561e7f0cf1546" -> null
      - domain                   = "vpc" -> null
      - id                       = "eipalloc-0524bf23721b46672" -> null
      - network_border_group     = "us-east-1" -> null
      - network_interface        = "eni-037ad424f9cae990e" -> null
      - private_dns              = "ip-10-10-10-152.ec2.internal" -> null
      - private_ip               = "10.10.10.152" -> null
      - public_dns               = "ec2-52-1-34-117.compute-1.amazonaws.com" -> null
      - public_ip                = "52.1.34.117" -> null
      - public_ipv4_pool         = "amazon" -> null
      - tags                     = {} -> null
      - tags_all                 = {} -> null
      - vpc                      = true -> null
        # (4 unchanged attributes hidden)
    }

  # module.network.module.nat_gateway.aws_nat_gateway.nat will be destroyed
  - resource "aws_nat_gateway" "nat" {
      - allocation_id                      = "eipalloc-0524bf23721b46672" -> null
      - association_id                     = "eipassoc-0640561e7f0cf1546" -> null
      - connectivity_type                  = "public" -> null
      - id                                 = "nat-02beee08af1764a16" -> null
      - network_interface_id               = "eni-037ad424f9cae990e" -> null
      - private_ip                         = "10.10.10.152" -> null
      - public_ip                          = "52.1.34.117" -> null
      - secondary_allocation_ids           = [] -> null
      - secondary_private_ip_address_count = 0 -> null
      - secondary_private_ip_addresses     = [] -> null
      - subnet_id                          = "subnet-024c40f6cd37e56ad" -> null
      - tags                               = {} -> null
      - tags_all                           = {} -> null
    }

  # module.network.module.route_tables.aws_route_table.private will be destroyed
  - resource "aws_route_table" "private" {
      - arn              = "arn:aws:ec2:us-east-1:767397961434:route-table/rtb-079f013a4d5b6e2cd" -> null
      - id               = "rtb-079f013a4d5b6e2cd" -> null
      - owner_id         = "767397961434" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - cidr_block                 = "0.0.0.0/0"
              - nat_gateway_id             = "nat-02beee08af1764a16"
                # (11 unchanged attributes hidden)
            },
        ] -> null
      - tags             = {} -> null
      - tags_all         = {} -> null
      - vpc_id           = "vpc-0269c6e22c190485a" -> null
    }

  # module.network.module.route_tables.aws_route_table.public will be destroyed
  - resource "aws_route_table" "public" {
      - arn              = "arn:aws:ec2:us-east-1:767397961434:route-table/rtb-0d60aac02416a1108" -> null
      - id               = "rtb-0d60aac02416a1108" -> null
      - owner_id         = "767397961434" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - cidr_block                 = "0.0.0.0/0"
              - gateway_id                 = "igw-04741444a78117f46"
                # (11 unchanged attributes hidden)
            },
        ] -> null
      - tags             = {} -> null
      - tags_all         = {} -> null
      - vpc_id           = "vpc-0269c6e22c190485a" -> null
    }

  # module.network.module.route_tables.aws_route_table_association.private[0] will be destroyed
  - resource "aws_route_table_association" "private" {
      - id             = "rtbassoc-0de66a8d9a408983c" -> null
      - route_table_id = "rtb-079f013a4d5b6e2cd" -> null
      - subnet_id      = "subnet-026cda4c841d76183" -> null
        # (1 unchanged attribute hidden)
    }

  # module.network.module.route_tables.aws_route_table_association.private[1] will be destroyed
  - resource "aws_route_table_association" "private" {
      - id             = "rtbassoc-06abccb9652d10c05" -> null
      - route_table_id = "rtb-079f013a4d5b6e2cd" -> null
      - subnet_id      = "subnet-00254097f2241969f" -> null
        # (1 unchanged attribute hidden)
    }

  # module.network.module.route_tables.aws_route_table_association.public[0] will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-0df28f5b5f2f6b064" -> null
      - route_table_id = "rtb-0d60aac02416a1108" -> null
      - subnet_id      = "subnet-024c40f6cd37e56ad" -> null
        # (1 unchanged attribute hidden)
    }

  # module.network.module.route_tables.aws_route_table_association.public[1] will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-0ec7b172e67cf545c" -> null
      - route_table_id = "rtb-0d60aac02416a1108" -> null
      - subnet_id      = "subnet-0a1e8723a85ab9331" -> null
        # (1 unchanged attribute hidden)
    }

  # module.network.module.subnets.aws_subnet.private[0] will be destroyed
  - resource "aws_subnet" "private" {
      - arn                                            = "arn:aws:ec2:us-east-1:767397961434:subnet/subnet-026cda4c841d76183" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1a" -> null
      - availability_zone_id                           = "use1-az6" -> null
      - cidr_block                                     = "10.10.12.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-026cda4c841d76183" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = false -> null
      - owner_id                                       = "767397961434" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name" = "example-private-0"
        } -> null
      - tags_all                                       = {
          - "Name" = "example-private-0"
        } -> null
      - vpc_id                                         = "vpc-0269c6e22c190485a" -> null
        # (4 unchanged attributes hidden)
    }

  # module.network.module.subnets.aws_subnet.private[1] will be destroyed
  - resource "aws_subnet" "private" {
      - arn                                            = "arn:aws:ec2:us-east-1:767397961434:subnet/subnet-00254097f2241969f" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1b" -> null
      - availability_zone_id                           = "use1-az1" -> null
      - cidr_block                                     = "10.10.13.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-00254097f2241969f" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = false -> null
      - owner_id                                       = "767397961434" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name" = "example-private-1"
        } -> null
      - tags_all                                       = {
          - "Name" = "example-private-1"
        } -> null
      - vpc_id                                         = "vpc-0269c6e22c190485a" -> null
        # (4 unchanged attributes hidden)
    }

  # module.network.module.subnets.aws_subnet.public[0] will be destroyed
  - resource "aws_subnet" "public" {
      - arn                                            = "arn:aws:ec2:us-east-1:767397961434:subnet/subnet-024c40f6cd37e56ad" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1a" -> null
      - availability_zone_id                           = "use1-az6" -> null
      - cidr_block                                     = "10.10.10.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-024c40f6cd37e56ad" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "767397961434" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name" = "example-public-0"
        } -> null
      - tags_all                                       = {
          - "Name" = "example-public-0"
        } -> null
      - vpc_id                                         = "vpc-0269c6e22c190485a" -> null
        # (4 unchanged attributes hidden)
    }

  # module.network.module.subnets.aws_subnet.public[1] will be destroyed
  - resource "aws_subnet" "public" {
      - arn                                            = "arn:aws:ec2:us-east-1:767397961434:subnet/subnet-0a1e8723a85ab9331" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1b" -> null
      - availability_zone_id                           = "use1-az1" -> null
      - cidr_block                                     = "10.10.11.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-0a1e8723a85ab9331" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "767397961434" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name" = "example-public-1"
        } -> null
      - tags_all                                       = {
          - "Name" = "example-public-1"
        } -> null
      - vpc_id                                         = "vpc-0269c6e22c190485a" -> null
        # (4 unchanged attributes hidden)
    }

  # module.network.module.vpc.aws_vpc.main will be destroyed
  - resource "aws_vpc" "main" {
      - arn                                  = "arn:aws:ec2:us-east-1:767397961434:vpc/vpc-0269c6e22c190485a" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.10.0.0/16" -> null
      - default_network_acl_id               = "acl-08821cc309df88905" -> null
      - default_route_table_id               = "rtb-0e4992152436e23ba" -> null
      - default_security_group_id            = "sg-059f9ffc4dede66c5" -> null
      - dhcp_options_id                      = "dopt-097221ed8fdf1b4f4" -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-0269c6e22c190485a" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-0e4992152436e23ba" -> null
      - owner_id                             = "767397961434" -> null
      - tags                                 = {
          - "Name" = "example-vpc"
        } -> null
      - tags_all                             = {
          - "Name" = "example-vpc"
        } -> null
        # (4 unchanged attributes hidden)
    }

  # module.network.module.vpc_endpoint.aws_vpc_endpoint.s3 will be destroyed
  - resource "aws_vpc_endpoint" "s3" {
      - arn                   = "arn:aws:ec2:us-east-1:767397961434:vpc-endpoint/vpce-08f927858fe08b3d7" -> null
      - cidr_blocks           = [
          - "16.182.0.0/16",
          - "18.34.0.0/19",
          - "52.216.0.0/15",
          - "54.231.0.0/16",
          - "3.5.0.0/19",
          - "18.34.232.0/21",
        ] -> null
      - dns_entry             = [] -> null
      - id                    = "vpce-08f927858fe08b3d7" -> null
      - network_interface_ids = [] -> null
      - owner_id              = "767397961434" -> null
      - policy                = jsonencode(
            {
              - Statement = [
                  - {
                      - Action    = "*"
                      - Effect    = "Allow"
                      - Principal = "*"
                      - Resource  = "*"
                    },
                ]
              - Version   = "2008-10-17"
            }
        ) -> null
      - prefix_list_id        = "pl-63a5400a" -> null
      - private_dns_enabled   = false -> null
      - requester_managed     = false -> null
      - route_table_ids       = [
          - "rtb-079f013a4d5b6e2cd",
        ] -> null
      - security_group_ids    = [] -> null
      - service_name          = "com.amazonaws.us-east-1.s3" -> null
      - state                 = "available" -> null
      - subnet_ids            = [] -> null
      - tags                  = {} -> null
      - tags_all              = {} -> null
      - vpc_endpoint_type     = "Gateway" -> null
      - vpc_id                = "vpc-0269c6e22c190485a" -> null
        # (1 unchanged attribute hidden)
    }

Plan: 0 to add, 0 to change, 15 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

module.network.module.route_tables.aws_route_table_association.public[0]: Destroying... [id=rtbassoc-0df28f5b5f2f6b064]
module.network.module.route_tables.aws_route_table_association.private[0]: Destroying... [id=rtbassoc-0de66a8d9a408983c]
module.network.module.route_tables.aws_route_table_association.public[1]: Destroying... [id=rtbassoc-0ec7b172e67cf545c]
module.network.module.route_tables.aws_route_table_association.private[1]: Destroying... [id=rtbassoc-06abccb9652d10c05]
module.network.module.vpc_endpoint.aws_vpc_endpoint.s3: Destroying... [id=vpce-08f927858fe08b3d7]
module.network.module.route_tables.aws_route_table_association.private[1]: Destruction complete after 1s
module.network.module.route_tables.aws_route_table_association.public[0]: Destruction complete after 1s
module.network.module.route_tables.aws_route_table_association.public[1]: Destruction complete after 1s
module.network.module.route_tables.aws_route_table_association.private[0]: Destruction complete after 1s
module.network.module.route_tables.aws_route_table.public: Destroying... [id=rtb-0d60aac02416a1108]
module.network.module.subnets.aws_subnet.private[0]: Destroying... [id=subnet-026cda4c841d76183]
module.network.module.subnets.aws_subnet.private[1]: Destroying... [id=subnet-00254097f2241969f]
module.network.module.subnets.aws_subnet.private[1]: Destruction complete after 1s
module.network.module.subnets.aws_subnet.private[0]: Destruction complete after 1s
module.network.module.route_tables.aws_route_table.public: Destruction complete after 1s
module.network.module.internet_gateway.aws_internet_gateway.gw: Destroying... [id=igw-04741444a78117f46]
module.network.module.vpc_endpoint.aws_vpc_endpoint.s3: Destruction complete after 7s
module.network.module.route_tables.aws_route_table.private: Destroying... [id=rtb-079f013a4d5b6e2cd]
module.network.module.route_tables.aws_route_table.private: Destruction complete after 1s
module.network.module.nat_gateway.aws_nat_gateway.nat: Destroying... [id=nat-02beee08af1764a16]
module.network.module.internet_gateway.aws_internet_gateway.gw: Still destroying... [id=igw-04741444a78117f46, 10s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still destroying... [id=nat-02beee08af1764a16, 10s elapsed]
module.network.module.internet_gateway.aws_internet_gateway.gw: Still destroying... [id=igw-04741444a78117f46, 20s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still destroying... [id=nat-02beee08af1764a16, 20s elapsed]
module.network.module.internet_gateway.aws_internet_gateway.gw: Still destroying... [id=igw-04741444a78117f46, 30s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still destroying... [id=nat-02beee08af1764a16, 30s elapsed]
module.network.module.internet_gateway.aws_internet_gateway.gw: Still destroying... [id=igw-04741444a78117f46, 40s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still destroying... [id=nat-02beee08af1764a16, 40s elapsed]
module.network.module.internet_gateway.aws_internet_gateway.gw: Still destroying... [id=igw-04741444a78117f46, 50s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Still destroying... [id=nat-02beee08af1764a16, 50s elapsed]
module.network.module.nat_gateway.aws_nat_gateway.nat: Destruction complete after 53s
module.network.module.subnets.aws_subnet.public[0]: Destroying... [id=subnet-024c40f6cd37e56ad]
module.network.module.nat_gateway.aws_eip.nat: Destroying... [id=eipalloc-0524bf23721b46672]
module.network.module.subnets.aws_subnet.public[1]: Destroying... [id=subnet-0a1e8723a85ab9331]
module.network.module.internet_gateway.aws_internet_gateway.gw: Destruction complete after 1m0s
module.network.module.subnets.aws_subnet.public[1]: Destruction complete after 1s
module.network.module.subnets.aws_subnet.public[0]: Destruction complete after 1s
module.network.module.vpc.aws_vpc.main: Destroying... [id=vpc-0269c6e22c190485a]
module.network.module.nat_gateway.aws_eip.nat: Destruction complete after 2s
module.network.module.vpc.aws_vpc.main: Destruction complete after 1s

Destroy complete! Resources: 15 destroyed.

```
