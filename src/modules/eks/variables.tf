variable "lab_role" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_private_subnets" {
  description = "The private subnets CIDR blocks."
  type        = list(string)
}
