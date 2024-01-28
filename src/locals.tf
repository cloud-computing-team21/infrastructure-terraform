# Availability zones.
locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.vpc_az_count)
}

# Resource names.
locals {
  vpc_name                = "vpc"
  public_subnet_names     = [for i in range(length(var.vpc_public_subnets)) : format("subnet-public-%d", i + 1)]
  private_subnet_names    = [for i in range(length(var.vpc_private_subnets)) : format("subnet-private-%d", i + 1)]
  igw_name                = "igw"
  nat_gateway_name        = "nat"
  ec2_key_name            = "key-ec2"
  ec2_security_group_name = "ec2"
  bastion_name            = "bastion-host"
  backend_names           = [for i in range(length(local.availability_zones)) : format("backend-%d", i + 1)]
  rds_name                = "rds"
  rds_subnet_group_name   = "rds-subnet-group"
  rds_security_group_name = "rds"
  aurora_name             = "rds-aurora"
}
