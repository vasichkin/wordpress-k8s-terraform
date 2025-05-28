resource "kubernetes_service" "grafana_nodeport" {
  metadata {
    name      = "grafana-nodeport"
    namespace = "monitoring"
  }

  spec {
    type = "NodePort"

    selector = {
      "app.kubernetes.io/instance" = "kube-prometheus-stack"
      "app.kubernetes.io/name"     = "grafana"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 3000
      node_port   = 30300
    }
  }
}
