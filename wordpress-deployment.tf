
resource "kubernetes_persistent_volume" "wordpress_pv" {
  metadata {
    name      = "wordpress-pv"
  }

  spec {
    capacity = {
      storage = var.wordpress_storage
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name                = "manual"

    persistent_volume_source {
      host_path {
        path = var.wordpress_host_path
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress_pvc" {
  metadata {
    name      = "wordpress-pvc"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.wordpress_storage
      }
    }

    storage_class_name = "manual"
  }
}

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = var.namespace
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "wordpress"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }

      spec {
        container {
          name  = "wordpress"
          image = var.wordpress_image

          port {
            container_port = 80
            name           = "wordpress"
          }

          volume_mount {
            name       = "wordpress-data"
            mount_path = "/var/www/html"
          }

          env {
            name  = "WORDPRESS_DB_HOST"
            value = "mysql-service.${var.namespace}.svc.cluster.local"
          }

          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "MYSQL_ROOT_PASSWORD"
              }
            }
          }

          env {
            name  = "WORDPRESS_DB_USER"
            value = "root"
          }

          env {
            name  = "WORDPRESS_DB_NAME"
            value = "mysql"
          }
        }

        volume {
          name = "wordpress-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.wordpress_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress_service" {
  metadata {
    name      = "wordpress-service"
    namespace = var.namespace
  }

  spec {
    type = "NodePort"

    selector = {
      app = "wordpress"
    }

    port {
      name       = "http"
      protocol   = "TCP"
      port       = 80
      target_port = 80
      node_port  = 30007
    }
  }
}
