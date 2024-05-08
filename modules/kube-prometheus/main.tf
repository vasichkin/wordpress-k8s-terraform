resource "helm_release" "kube-prometheus" {
  name       = "kube-prometheus-stack"
  namespace  = var.monitor_namespace
  version    = var.monitor-version
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
}
