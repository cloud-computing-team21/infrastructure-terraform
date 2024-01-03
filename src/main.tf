################################################################################
# VPC
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc"
  cidr = var.vpc_cidr

  azs             = local.availability_zones
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = var.tags
}

################################################################################
# EC2
################################################################################

resource "aws_key_pair" "this" {
  key_name   = "key-ec2"
  public_key = file(var.public_key_path)

  tags = merge(
    {
      Name = "key-ec2"
    },
    var.tags
  )
}

module "security_group_ec2" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "ec2"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = var.ingress_cidr_blocks
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = var.tags
}

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "ec2"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  availability_zone           = element(data.aws_availability_zones.available.names, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.security_group_ec2.security_group_id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  tags = var.tags
}

################################################################################
# RDS
################################################################################

resource "aws_db_subnet_group" "this" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = merge(
    {
      Name = "subnet-group-rds"
    },
    var.tags
  )
}

module "security_group_rds" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "rds"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.rds_port
      to_port     = var.rds_port
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = var.tags
}

module "rds" {
  source = "./modules/rds"

  count = !var.use_aurora ? 1 : 0

  identifier = "rds"
  db_name    = "rds-db"

  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  username = var.username
  password = var.password

  availability_zones     = local.availability_zones
  port                   = var.rds_port
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [module.security_group_rds.security_group_id]

  storage_type          = var.rds_storage_type
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage

  backup_retention_period = 1
  backup_window           = "03:00-06:00"

  tags = var.tags
}

################################################################################
# Aurora
################################################################################

module "rds_aurora" {
  source = "./modules/rds_aurora"

  count = var.use_aurora ? 1 : 0

  identifier = "rds-aurora"

  engine           = var.aurora_engine
  engine_version   = var.aurora_engine_version
  instance_classes = [for az in local.availability_zones : var.aurora_instance_class]

  username = var.username
  password = var.password

  availability_zones     = local.availability_zones
  port                   = var.rds_port
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [module.security_group_rds.security_group_id]

  backup_retention_period = 1
  backup_window           = "03:00-06:00"

  tags = var.tags
}
