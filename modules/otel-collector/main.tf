resource "helm_release" "opentelemetry-collector" {
  name       = "opentelemetry-collector"
  namespace  = var.monitor_namespace
  version    = var.otel-collector-version
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  values = [templatefile("modules/otel-collector/values.yaml", {})]

}
