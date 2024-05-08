resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name      = "mysql-secret"
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    MYSQL_ROOT_PASSWORD = var.mysql_root_password
  }
}


resource "kubernetes_persistent_volume" "mysql_pv" {
  metadata {
    name = "mysql-pv"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = var.mysql_storage
    }
    
    persistent_volume_source {
      host_path {
        path = var.mysql_host_path
      }
    }
  }
}


resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name = "mysql-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.mysql_storage
      }
    }
    selector {
      match_labels = {
        app = "mysql"
      }
    }
  }
}

resource "kubernetes_stateful_set" "mysql" {
  metadata {
    name      = "mysql"
    namespace = var.namespace
  }
  spec {
    replicas     = 1
    service_name = "mysql"
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
        container {
          name  = "database"
          image = var.mysql_image
          args  = ["--ignore-db-dir=lost+found"]
          env_from {
            secret_ref {
              name = kubernetes_secret.mysql_secret.metadata[0].name
            }
          }
          port {
            container_port = 3306
          }
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mysql-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql_service" {
  metadata {
    name      = "mysql-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "mysql"
    }
    port {
      port        = 3306
      protocol    = "TCP"
    }
  }
}