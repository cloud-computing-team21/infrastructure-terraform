resource "aws_db_instance" "master" {
  identifier = "${var.identifier}-master"
  db_name    = var.db_name

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Database root credentials.
  username = var.username
  password = var.password

  port                   = var.port
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  # Storage and backup.
  storage_type          = var.storage_type
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = false

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  skip_final_snapshot     = true

  # True for master-standby replication along the subnet group assigned before.
  multi_az = true

  tags = var.tags
}

resource "aws_db_instance" "read_replica" {
  count = var.read_replica_count

  identifier = "${var.identifier}-read-replica"

  # This is a read replica, set its master identifier.
  replicate_source_db = aws_db_instance.master.id

  availability_zone      = var.availability_zones[count.index]
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  instance_class = var.instance_class

  # Storage and backup.
  storage_type          = var.storage_type
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = false

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  skip_final_snapshot     = true

  tags = var.tags
}
