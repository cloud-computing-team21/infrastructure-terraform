resource "aws_db_instance" "master" {
  identifier = "${var.identifier}-master"
  db_name    = var.db_name

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  storage_type   = var.storage_type

  username = var.username
  password = var.password

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  port                  = var.port

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  backup_window = var.backup_window

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
  storage_encrypted       = false

  # Standby replica
  multi_az = true
}

resource "aws_db_instance" "read_replica" {
  count = length(var.replica_azs)

  identifier = "${var.identifier}-read-replica"

  replicate_source_db = aws_db_instance.master.id

  instance_class = var.instance_class

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  backup_retention_period = 0

  skip_final_snapshot = true
  storage_encrypted   = false

  availability_zone = var.replica_azs[count.index]
}
