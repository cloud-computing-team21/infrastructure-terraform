resource "helm_release" "nginx-ingress-controller" {
  name = "nginx-ingress-controller"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.1"
  namespace  = "kube-system"
}
