variable "namespace" {
  description = "Namespace to use"
}

variable "wordpress_domain_name" {
  description = "Site domain name to set"
}

variable "monitor_namespace" {
  type    = string
  default = "monitoring"
  description = "Namespace to use for monitoring apps"
}

variable "aws_tags" {
  type   = map(string)
}

variable "aws_region" {
  type   = string
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

module "ingress-nginx" {
  source = "./modules/ingress-nginx"
  nginx-version = "4.12.2"
}

#module "aws-ebs-csi-driver" {
#  source = "./modules/aws-ebs-csi-driver"
#  aws_tags = var.aws_tags
#  aws_region = "${var.aws_region}"
#}

#module "loki-stack" {
#  source = "./modules/loki-stack"
#  monitor-version = "2.10.2"
#}

#module "influxdb" {
#  source = "./modules/influxdb"
#  influxdb-version = "4.12.3"
#}

#module "telegraf" {
#  source = "./modules/telegraf"
#  telegraf-version = "1.8.45"
#}

#module "otel-collector" {
#  source = "./modules/otel-collector"
#  otel-collector-version = "0.90.1"
#}