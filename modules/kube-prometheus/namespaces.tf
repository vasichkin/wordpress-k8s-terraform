resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitor_namespace
  }
}
