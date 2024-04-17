# Exercise 1

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
