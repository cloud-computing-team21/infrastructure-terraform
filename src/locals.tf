# Availability zones.
locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.vpc_az_count)
}

# Resource names.
locals {
  vpc_name                = "vpc"
  bastion_name            = "bastion-host"
  bastion_key_name        = "key-bastion-host"
  rds_name                = "rds"
  rds_subnet_group_name   = "rds-subnet-group"
  rds_security_group_name = "rds"
  aurora_name             = "rds-aurora"
}
