variable "region" {
  description = "The selected AWS region."
  type        = string
  default     = "us-east-1"
}

################################################################################
# VPC
################################################################################

variable "vpc_cidr" {
  description = "The main VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "The private subnets CIDR blocks."
  type        = list(string)
  default = [
    "10.0.0.0/18",
    "10.0.128.0/18"
  ]
}

variable "public_subnet_cidrs" {
  description = "The public subnets CIDR blocks."
  type        = list(string)
  default = [
    "10.0.64.0/18",
    "10.0.192.0/18"
  ]
}

variable "az_count" {
  description = "The number of Availability Zones in the VPC."
  type        = number
  default     = 2
}

################################################################################
# EC2
################################################################################

variable "ingress_cidr_blocks" {
  description = "The CIDR block allowed for ingress connections to the EC2 instances."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "The type of the EC2 instances."
  type        = string
  default     = "t4g.nano"
}

variable "public_key_path" {
  description = "The path of the public key to use for the EC2 instances"
  type        = string
  default     = null
}

################################################################################
# RDS
################################################################################

variable "engine" {
  description = "TThe DB engine to use."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The DB engine version to use."
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

variable "allocated_storage" {
  description = "The amount of storage (in gigabytes) that is initially allocated for the DB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance."
  type        = number
  default     = 30
}

variable "username" {
  description = "Username for the master DB user."
  type        = string
}

variable "password" {
  description = "Password for the master DB user."
  type        = string
}

variable "rds_port" {
  description = "The port on which the DB accepts connections."
  type        = number
  default     = 5432
}

################################################################################
# All
################################################################################

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default = {
    GithubRepo         = "cloud-computing-team21"
    PostgraduateCourse = "UPC Cloud Computing"
    Project            = "Final Postgraduate Project - Team 21"
  }
}
