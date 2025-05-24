#resource "kubernetes_storage_class" "default_gp3" {
#  metadata {
#    name = "gp3-default"
#    annotations = {
#      "storageclass.kubernetes.io/is-default-class" = "true"
#    }
#  }
#
#  storage_provisioner = "ebs.csi.aws.com"
#
#  parameters = {
#    type   = "gp3"
#    fsType = "ext4"
#  }

#  reclaim_policy         = "Delete"
#  volume_binding_mode    = "WaitForFirstConsumer"
#  allow_volume_expansion = true
#}


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


resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name      = "mysql-pvc"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.mysql_storage
      }
    }

    storage_class_name = "manual"
  }
}

## Uncomment for local/predefined storage

resource "kubernetes_persistent_volume" "wordpress_pv" {
  metadata {
    name      = "wordpress-pv"
    labels = {
        app = "wordpress"
        function = "wordpress_data_storage"
    }
  }
  spec {
    capacity = {
      storage = var.wordpress_storage
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy  = "Retain"
    storage_class_name                = "manual"
    persistent_volume_source {
      host_path {
        path = var.wordpress_host_path
      }
    }
  }
}


## Uncomment for local/predefined storage

resource "kubernetes_persistent_volume" "mysql_pv" {
  metadata {
    name = "mysql-pv"
    labels = {
        app = "mysql"
        function = "mysql_database_storage"
    }
  }
  spec {
    capacity = {
      storage = var.mysql_storage
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy  = "Retain"
    storage_class_name                = "manual"
    persistent_volume_source {
      host_path {
        path = var.mysql_host_path
      }
    }
  }
}



