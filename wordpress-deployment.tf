resource "kubernetes_namespace" "wordpress-namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace" "monitor-namespace" {
  metadata {
    name = var.monitor_namespace
  }
}

resource "kubernetes_config_map" "php_fpm_config" {
  metadata {
    name      = "php-fpm-config"
    namespace = var.namespace
  }

  data = {
    "www.conf" = <<-EOT
      [www]
      user = www-data
      group = www-data
      listen = 127.0.0.1:9000
      pm = dynamic
      pm.status_path = /status
      pm.max_children = 5
      pm.start_servers = 2
      pm.min_spare_servers = 1
      pm.max_spare_servers = 3
    EOT
  }
}

resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "nginx-config"
    namespace = var.namespace
  }

  data = {
    "default.conf" = <<-EOT
      server {
          listen 80;
          root /var/www/html;
          index index.php index.html;

          location / {
              try_files \$uri \$uri/ /index.php?\$args;
          }

          location ~ \.php\$ {
              include fastcgi_params;
              fastcgi_pass 127.0.0.1:9000;
              fastcgi_index index.php;
              fastcgi_param SCRIPT_FILENAME /var/www/html\$fastcgi_script_name;
          }

          location ~ /\.ht {
              deny all;
          }
      }
    EOT
  }
}

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = var.namespace
  }

  spec {
    replicas = 1

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
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "9253"
          "prometheus.io/path"   = "/metrics"
        }
      }

      spec {
        container {
          name  = "wordpress"
          image = var.wordpress_image

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

          env {
            name  = "WORDPRESS_SITE_URL"
            value = var.wordpress_domain_name
          }

          env {
            name  = "WORDPRESS_HOME"
            value = var.wordpress_domain_name
          }

          port {
            name           = "fpm"
            container_port = 9000
          }

          volume_mount {
            name       = "wordpress-data"
            mount_path = "/var/www/html"
          }

          volume_mount {
            name       = "php-config"
            mount_path = "/usr/local/etc/php-fpm.d/www.conf"
            sub_path   = "www.conf"
          }
        }

        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            name           = "http"
            container_port = 80
          }

          volume_mount {
            name       = "wordpress-data"
            mount_path = "/var/www/html"
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d"
          }
        }

        container {
          name  = "php-fpm-exporter"
          image = "hipages/php-fpm_exporter:latest"

          args = [
            "--phpfpm.scrape-uri=tcp://127.0.0.1:9000/status"
          ]

          port {
            name           = "metrics"
            container_port = 9253
          }
        }

        volume {
          name = "wordpress-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.wordpress_pvc.metadata[0].name
          }
        }

        volume {
          name = "php-config"
          config_map {
            name = kubernetes_config_map.php_fpm_config.metadata[0].name
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
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
      name        = "http"
      port        = 80
      target_port = "http"
      node_port   = 30080
    }
  }
}
