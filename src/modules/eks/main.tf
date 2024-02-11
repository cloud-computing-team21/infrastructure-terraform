module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.1.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = var.vpc_id
  subnet_ids = var.vpc_private_subnets

  create_iam_role = false
  iam_role_arn    = var.iam_role_arn
  enable_irsa     = false

  kms_key_enable_default_policy = true

  eks_managed_node_group_defaults = {
    disk_size = 20
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 3
      min_size     = 1
      max_size     = 4

      create_iam_role = false
      iam_role_arn    = var.iam_role_arn

      labels = {
        role = "general"
      }

      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "ON_DEMAND"
    }

    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 3

      create_iam_role = false
      iam_role_arn    = var.iam_role_arn

      labels = {
        role = "spot"
      }

      taints = [{
        key    = "market"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }]

      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "SPOT"
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  tags = merge(
    {
      Name = var.cluster_name
    },
    var.tags
  )
}
