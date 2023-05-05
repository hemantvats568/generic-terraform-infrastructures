resource "aws_vpc" "new_vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.tenancy

  #Additional attributes for eks private endpoint access
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "example-vpc"
  }
}
