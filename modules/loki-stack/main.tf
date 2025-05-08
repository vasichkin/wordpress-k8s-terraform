resource "helm_release" "loki-stack" {
  name       = "loki-stack"
  namespace  = var.monitor_namespace
  version    = var.monitor-version
  repository = "https://grafana.github.io/helm-charts/"
  chart      = "loki-stack"
  values = [templatefile("modules/loki-stack/values.yaml", {})]

}
