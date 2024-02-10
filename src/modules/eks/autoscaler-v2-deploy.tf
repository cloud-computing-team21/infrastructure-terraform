resource "helm_release" "cluster_autoscaler" {
  name = "cluster-autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.35.0"
  namespace  = "kube-system"

  set {
    name  = "awsRegion"
    value = "us-east-1"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = "dei-eks"
  }

  set {
    name  = "autoscalingGroups[0].name"
    value = "eks-general-20240210101243824300000008-10c6c940-a683-b066-b9d0-9c7bb0f99250"
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
