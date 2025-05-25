resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  namespace  = var.monitor_namespace
  version    = var.monitor-version
  repository = "https://prometheus-community.github.io/helm-charts/"
  chart      = "kube-prometheus-stack"
  values = [templatefile("modules/kube-prometheus-stack/values.yaml", {})]

}
