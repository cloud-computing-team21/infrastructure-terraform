
################################################################################
# Common
################################################################################

resource "aws_key_pair" "this" {
  key_name   = local.ec2_key_name
  public_key = file(var.public_key)

  tags = merge(
    {
      Name = local.ec2_key_name
    },
    var.tags
  )
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.3"

  name = local.vpc_name
  cidr = var.vpc_cidr

  azs            = local.availability_zones
  public_subnets = var.vpc_public_subnets
  #   public_subnet_names  = local.public_subnet_names
  private_subnets = var.vpc_private_subnets
  #   private_subnet_names = local.private_subnet_names

  # Configure just one NAT in the first public subnet.
  enable_nat_gateway = true
  single_nat_gateway = true

  igw_tags         = { Name = local.igw_name }
  nat_gateway_tags = { Name = local.nat_gateway_name }
  tags             = var.tags
}

################################################################################
# Bastion Host
################################################################################

module "bastion_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name   = local.ec2_security_group_name
  vpc_id = module.vpc.vpc_id

  # Allow SSH and ICMP from the CIDR blocks provided.
  ingress_cidr_blocks = var.bastion_ingress_cidr_blocks
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = var.tags
}

module "bastion_host_ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = local.bastion_name

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.bastion_instance_type

  # Place the bastion in the first AZ and public subnet.
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  subnet_id         = element(module.vpc.public_subnets, 0)

  # Set the previously defined security group.
  vpc_security_group_ids = [module.bastion_security_group.security_group_id]

  # Configure the public key.
  key_name = aws_key_pair.this.key_name

  # Associate a public IP as we need to access it from outside.
  associate_public_ip_address = true

  # Optionally pass the user data as a file.
  user_data = length(var.bastion_user_data_file) > 0 ? file(var.bastion_user_data_file) : ""

  tags = var.tags
}

################################################################################
# EC2
################################################################################

module "ec2_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name   = local.ec2_security_group_name
  vpc_id = module.vpc.vpc_id

  # Allow SSH and ICMP from the bastion host.
  ingress_cidr_blocks = [local.bastion_host_private_cidr_block]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  # Custom ingress rule for HTTP on port 9966.
  ingress_with_cidr_blocks = [
    {
      from_port   = 9966
      to_port     = 9966
      protocol    = "tcp"
      description = "Custom HTTP rule for port 9966"
      cidr_blocks = local.bastion_host_private_cidr_block
    }
  ]

  tags = var.tags
}

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  # True for adding an EC2 instance to the first private subnet of each AZ.
  count = var.use_ec2 ? var.vpc_az_count : 0

  name = local.ec2_names[count.index]

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  # Place the EC2 in the first private subnet of each AZ.
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  subnet_id         = element(module.vpc.private_subnets, count.index)

  # Set the previously defined security group.
  vpc_security_group_ids = [module.ec2_security_group.security_group_id]

  # Configure the public key.
  key_name = aws_key_pair.this.key_name

  # Optionally pass the user data as a file.
  user_data = length(var.ec2_user_data_file) > 0 ? file(var.ec2_user_data_file) : ""

  tags = var.tags
}

################################################################################
# EKS
################################################################################

module "eks" {
  source = "./modules/eks"

  cluster_name    = local.eks_cluster_name
  cluster_version = var.eks_cluster_version
  cluster_region = var.region

  # The VPC information where the EKS will be provisioned.
  vpc_id              = module.vpc.vpc_id
  vpc_private_subnets = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  # The IAM role, use the LabRole if deploying in Academy.
  iam_role_arn = var.eks_iam_role_arn

  tags = var.tags
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

  tags = var.tags
}

module "rds" {
  source = "./modules/rds"

  # True for RDS, false for Aurora.
  count = var.use_rds ? 1 : 0

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

  tags = var.tags
}

################################################################################
# Aurora
################################################################################

module "rds_aurora" {
  source = "./modules/rds_aurora"

  # True for RDS, false for Aurora.
  count = !var.use_rds ? 1 : 0

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

  tags = var.tags
}
