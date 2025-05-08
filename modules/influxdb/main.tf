resource "helm_release" "influxdb" {
  name       = "influxdb"
  namespace  = var.monitor_namespace
  version    = var.influxdb-version
  repository = "https://helm.influxdata.com/"
  chart      = "influxdb"
}
