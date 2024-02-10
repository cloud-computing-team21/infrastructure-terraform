
################################################################################
# VPC
################################################################################

variable "vpc_cidr" {
  description = "The main VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_az_count" {
  description = "The number of Availability Zones in the VPC."
  type        = number
  default     = 2
}

variable "vpc_public_subnets" {
  description = "The public subnets CIDR blocks."
  type        = list(string)
  default = [
    "10.0.0.0/18",  # First AZ
    "10.0.64.0/18", # Second AZ
  ]
}

variable "vpc_private_subnets" {
  description = "The private subnets CIDR blocks."
  type        = list(string)
  default = [
    "10.0.128.0/19", # First AZ
    "10.0.192.0/19", # Second AZ
    "10.0.160.0/19", # First AZ
    "10.0.224.0/19"  # Second AZ
  ]
}

################################################################################
# EC2 Common
################################################################################

variable "ec2_public_key" {
  description = "The path of the public key to use for the EC2 instances."
  type        = string
  default     = null
}

################################################################################
# Bastion Host
################################################################################

variable "bastion_ingress_cidr_blocks" {
  description = "The CIDR block allowed for ingress connections to the bastion host."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bastion_instance_type" {
  description = "The type of the bastion host."
  type        = string
  default     = "t2.micro" # Use an x86_64 instance type, our docker images are x86_64 -> https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/instance-types.html
}

variable "bastion_user_data_file" {
  description = "An optional file to upload to the bastion host as user data."
  type        = string
  default     = ""
}

################################################################################
# Backend Common 
################################################################################

variable "backend_use_eks" {
  description = "Set to true for using AWS EKS instead of a single EC2 instance for the backend."
  type        = bool
  default     = false
}

################################################################################
# Backend EC2
################################################################################

variable "backend_instance_type" {
  description = "The type of the backend EC2."
  type        = string
  default     = "t2.micro" # Use an x86_64 instance type, our docker images are x86_64 -> https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/instance-types.html
}

variable "backend_user_data_file" {
  description = "An optional file to upload to the backend EC2 as user data."
  type        = string
  default     = ""
}

################################################################################
# Backend EKS
################################################################################

variable "eks_lab_role" {
  description = "The LabRole of the user."
  type        = string
}

################################################################################
# DB Common
################################################################################

variable "db_username" {
  description = "Username for the master DB user."
  type        = string
}

variable "db_password" {
  description = "Password for the master DB user."
  type        = string
}

variable "db_use_aurora" {
  description = "Set to true for using Amazon Aurora instead of Amazon RDS."
  type        = bool
  default     = false
}

################################################################################
# DB RDS
################################################################################

variable "rds_engine" {
  description = "The DB engine to use."
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "The DB engine version to use."
  type        = string
  default     = "14"
}

variable "rds_instance_class" {
  description = "The class of the RDS instance."
  type        = string
  default     = "db.t4g.micro"
}

variable "rds_read_replica_count" {
  description = "The number of read replicas to configure in the RDS."
  type        = number
  default     = 0
}

variable "rds_port" {
  description = "The port on which the DB accepts connections."
  type        = number
  default     = 5432
}

variable "rds_storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (general purpose SSD that needs iops independently) or 'io1' (provisioned IOPS SSD)."
  type        = string
  default     = "gp2"
}

variable "rds_allocated_storage" {
  description = "The amount of storage (in gigabytes) that is initially allocated for the DB."
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance."
  type        = number
  default     = 30
}

################################################################################
# DB Aurora
################################################################################

variable "aurora_engine" {
  description = "The DB engine to use."
  type        = string
  default     = "aurora-postgresql"
}

variable "aurora_engine_version" {
  description = "The DB engine version to use."
  type        = string
  default     = "15.3"
}

variable "aurora_instance_class" {
  description = "The class of the Aurora instance."
  type        = string
  default     = "db.t4g.medium"
}

################################################################################
# Common
################################################################################

variable "region" {
  description = "The selected AWS region."
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default = {
    Github  = "https://github.com/cloud-computing-team21"
    Course  = "UPC Cloud Computing"
    Project = "Final Postgraduate Project - Team 21"
  }
}
