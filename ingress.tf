
resource "kubernetes_ingress_v1" "wordpress" {
  depends_on = [kubernetes_service.wordpress_service, kubernetes_deployment.wordpress, module.ingress-nginx]
  wait_for_load_balancer = true
  timeouts {
    create = "300s"
  }
  metadata {
    name = "wordpress"
    namespace = var.namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    #  "nginx.ingress.kubernetes.io/enable-opentelemetry" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "wordpress-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# Display load balancer hostname (typically present in AWS)
#output "load_balancer_hostname" {
#  value = kubernetes_ingress_v1.wordpress.status.0.load_balancer.0.ingress.0.hostname
#}

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
#output "load_balancer_ip" {
#  value = kubernetes_ingress_v1.wordpress.status.0.load_balancer.0.ingress.0.ip
#}
