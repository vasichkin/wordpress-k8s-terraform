resource "helm_release" "telegraf" {
  name       = "telegraf"
  namespace  = var.monitor_namespace
  version    = var.telegraf-version
  repository = "https://helm.influxdata.com/"
  chart      = "telegraf"
}
