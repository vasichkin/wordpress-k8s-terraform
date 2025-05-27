terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  backend "s3" {
    bucket    = "capstone-terraform-state"
    key       = "terraform/kuber-wordpress-state"
    region    = "eu-north-1"
    use_lockfile = true
  }
}

provider "kubernetes" {
  config_path = "kubeconfigs/config"
}

provider "helm" {
  kubernetes {
    config_path = "kubeconfigs/config"
  }
}

