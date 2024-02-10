data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_eks_cluster" "default" {
  name = module.eks.cluster_name
  depends_on = [
    module.eks.eks_managed_node_groups,
  ]
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
  depends_on = [
    module.eks.eks_managed_node_groups,
  ]
}
