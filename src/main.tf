################################################################################
# VPC
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = var.vpc_cidr

  azs             = local.availability_zones
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  # Configure just one NAT in the first public subnet.
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(
    {
      Name = local.vpc_name
    },
    var.tags
  )
}

################################################################################
# EC2 Bastion Host
################################################################################

resource "aws_key_pair" "this" {
  key_name   = local.bastion_key_name
  public_key = file(var.bastion_public_key)

  tags = merge(
    {
      Name = local.bastion_key_name
    },
    var.tags
  )
}

module "security_group_ec2" {
  source = "terraform-aws-modules/security-group/aws"

  name   = local.bastion_name
  vpc_id = module.vpc.vpc_id

  # Allow SSH and ICMP from the CIDR blocks provided.
  ingress_cidr_blocks = var.bastion_ingress_cidr_blocks
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = merge(
    {
      Name = local.bastion_name
    },
    var.tags
  )
}

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = local.bastion_name

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.bastion_instance_type

  # Place the bastion in the first AZ and public subnet.
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  subnet_id         = element(module.vpc.public_subnets, 0)

  # Set the previously defined security group.
  vpc_security_group_ids = [module.security_group_ec2.security_group_id]

  # Configure the public key.
  key_name = aws_key_pair.this.key_name

  # Associate a public IP as we need to access it from outside.
  associate_public_ip_address = true

  # Optionally pass the user data as a file.
  user_data = length(var.bastion_user_data_file) > 0 ? file(var.bastion_user_data_file) : ""

  tags = merge(
    {
      Name = local.bastion_name
    },
    var.tags
  )
}

################################################################################
# RDS
################################################################################

resource "aws_db_subnet_group" "this" {
  name       = local.rds_subnet_group_name
  subnet_ids = module.vpc.private_subnets

  tags = merge(
    {
      Name = local.rds_subnet_group_name
    },
    var.tags
  )
}

module "security_group_rds" {
  source = "terraform-aws-modules/security-group/aws"

  name   = local.rds_security_group_name
  vpc_id = module.vpc.vpc_id

  # Allow incoming traffic only for the configured port from the VPC's CIDR block.
  ingress_with_cidr_blocks = [
    {
      from_port   = var.rds_port
      to_port     = var.rds_port
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = merge(
    {
      Name = local.rds_security_group_name
    },
    var.tags
  )
}

module "rds" {
  source = "./modules/rds"

  # True for Aurora, false for RDS.
  count = !var.db_use_aurora ? 1 : 0

  identifier = local.rds_name
  db_name    = local.rds_name

  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  # Number of replicas to configure.
  read_replica_count = var.rds_read_replica_count

  # Database root credentials.
  username = var.db_username
  password = var.db_password

  availability_zones   = local.availability_zones
  port                 = var.rds_port
  db_subnet_group_name = aws_db_subnet_group.this.name

  # Set the previously defined security group.
  vpc_security_group_ids = [module.security_group_rds.security_group_id]

  # Storage and backup.
  storage_type          = var.rds_storage_type
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage

  backup_retention_period = 1
  backup_window           = "03:00-06:00"

  tags = merge(
    {
      Name = local.rds_name
    },
    var.tags
  )
}

################################################################################
# Aurora
################################################################################

module "rds_aurora" {
  source = "./modules/rds_aurora"

  # True for Aurora, false for RDS.
  count = var.db_use_aurora ? 1 : 0

  identifier = local.aurora_name

  engine           = var.aurora_engine
  engine_version   = var.aurora_engine_version
  instance_classes = [for az in local.availability_zones : var.aurora_instance_class]

  # Database root credentials.
  username = var.db_username
  password = var.db_password

  availability_zones   = local.availability_zones
  port                 = var.rds_port
  db_subnet_group_name = aws_db_subnet_group.this.name

  # Set the previously defined security group.
  vpc_security_group_ids = [module.security_group_rds.security_group_id]

  # Storage and backup.
  backup_retention_period = 1
  backup_window           = "03:00-06:00"

  tags = merge(
    {
      Name = local.aurora_name
    },
    var.tags
  )
}
