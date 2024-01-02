variable "identifier" {
  description = "The name of the RDS instance."
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
  default     = "postgres"
}

variable "engine" {
  description = "The database engine to use."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The database engine version to use."
  type        = string
  default     = "14"
}

variable "instance_class" {
  description = "The class of the RDS instance."
  type        = string
  default     = "db.t4g.micro"
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (general purpose SSD that needs iops independently) or 'io1' (provisioned IOPS SSD)."
  type        = string
  default     = "gp2"
}

variable "username" {
  description = "Username for the master DB user."
  type        = string
}

variable "password" {
  description = "Password for the master DB user."
  type        = string
}

variable "allocated_storage" {
  description = "The amount of storage (in gigabytes) that is initially allocated for the DB."
  type        = number
  default     = 1
}

variable "max_allocated_storage" {
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance."
  type        = number
  default     = 2
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate."
  type        = list(string)
  default     = null
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled."
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "The days to retain backups for."
  type        = number
  default     = 0
}

variable "port" {
  description = "The port on which the DB accepts connections."
  type        = number
  default     = 5432
}

variable "replica_azs" {
  description = "List of availability zones for the read replicas."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = null
}
