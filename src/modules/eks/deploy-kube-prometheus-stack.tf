resource "helm_release" "kube-prometheus-stack" {
  name = "kube-prometheus-stack"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.2"
  create_namespace = true
  namespace  = "monitoring"
}
