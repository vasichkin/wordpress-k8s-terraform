terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
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

