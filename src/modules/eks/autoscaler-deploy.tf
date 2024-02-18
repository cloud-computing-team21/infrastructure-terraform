resource "helm_release" "cluster_autoscaler" {
  name = "cluster-autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.35.0"
  namespace  = "kube-system"

  set {
    name  = "awsRegion"
    value = var.cluster_region
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = "dei-eks"
  }

  set {
    name  = "autoscalingGroups[0].name"
    value = module.eks.eks_managed_node_groups["general"].node_group_autoscaling_group_names[0]
  }

  set {
    name  = "autoscalingGroups[0].maxSize"
    value = "5"
  }

  set {
    name  = "autoscalingGroups[0].minSize"
    value = "1"
  }
}
