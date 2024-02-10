variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to which the EKS cluster will be added."
  type        = string
}

variable "vpc_private_subnets" {
  description = "The private subnets CIDR blocks to which the EKS cluster will be provisioned."
  type        = list(string)
}

variable "iam_role_arn" {
  description = "The IAM role ARN for the EKS cluster."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
