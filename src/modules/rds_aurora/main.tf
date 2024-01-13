resource "aws_rds_cluster" "this" {
  cluster_identifier = var.identifier

  engine         = var.engine
  engine_version = var.engine_version

  # Database root credentials.
  master_username = var.username
  master_password = var.password

  availability_zones     = var.availability_zones
  port                   = var.port
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  # Storage and backup.
  storage_encrypted = false

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.backup_window
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "this" {
  # As many instances as availability zones, one per each.
  count = length(var.availability_zones)

  identifier         = "${aws_rds_cluster.this.id}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.this.id

  engine         = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version
  instance_class = var.instance_classes[count.index]

  availability_zone = var.availability_zones[count.index]
}
