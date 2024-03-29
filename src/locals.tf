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
  ec2_names               = [for i in range(length(local.availability_zones)) : format("ec2-%d", i + 1)]
  eks_cluster_name        = "eks-cluster"
  rds_name                = "petclinic"
  rds_subnet_group_name   = "rds-subnet-group"
  rds_security_group_name = "rds"
  aurora_name             = "rds-aurora"
}

# CIDR Blocks.
locals {
  bastion_host_private_cidr_blocks = [for bastion_host in module.bastion_hosts : format("%s/32", bastion_host.private_ip)]
}
