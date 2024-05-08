variable "namespace" {
  description = "Namespace to use"
}

variable "wordpress_storage" {
  description = "Storage capacity for the persistent volume"
}

variable "wordpress_host_path" {
  description = "Host path for the persistent volume"
}

variable "wordpress_image" {
  description = "Docker image for the WordPress container"
}

variable "mysql_storage" {
  description = "Storage capacity for the persistent volume"
}

variable "mysql_host_path" {
  description = "Host path for the persistent volume"
}

variable "mysql_image" {
  description = "Docker image for the MySQL container"
}

variable "mysql_root_password" {
  description = "Root password for MySQL"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

module "prometheus" {
  source = "./modules/kube-prometheus"
  monitor-version = "56.21.2"
}


module "ingress-nginx" {
  source = "./modules/ingress-nginx"
  nginx-version = "4.10.0"
}