resource "kubernetes_storage_class" "default_gp3" {
  depends_on = [module.aws-ebs-csi-driver]
  metadata {
    name = "gp3-default"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type   = "gp3"
    fsType = "ext4"
  }

  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}


# Create EBS Volumes to store data (not using dynamics volumes to be reliable)
resource "aws_ebs_volume" "wordpress_volume" {
  availability_zone = var.aws_region_zone
  size              = var.wordpress_storage
  type              = "gp3"
  tags = {
    Name = "wordpress-ebs"
  }
}

resource "aws_ebs_volume" "mysql_volume" {
  availability_zone = var.aws_region_zone
  size              = var.mysql_storage
  type              = "gp3"
  tags = {
    Name = "mysql-ebs"
  }
}

resource "kubernetes_persistent_volume" "wordpress_pv" {
  metadata {
    name = "wordpress-ebs-pv"
  }

  spec {
    capacity = {
      storage = var.wordpress_storage
    }

    access_modes       = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.default_gp3.metadata[0].name
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      csi {
        driver        = "ebs.csi.aws.com"
        volume_handle = aws_ebs_volume.wordpress_volume.id
        fs_type       = "ext4"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "mysql_pv" {
  metadata {
    name = "mysql-ebs-pv"
  }

  spec {
    capacity = {
      storage = var.mysql_storage
    }

    access_modes       = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.default_gp3.metadata[0].name
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      csi {
        driver        = "ebs.csi.aws.com"
        volume_handle = aws_ebs_volume.mysql_volume.id
        fs_type       = "ext4"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress_pvc" {
  depends_on = [kubernetes_storage_class.default_gp3]
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
    volume_name        = kubernetes_persistent_volume.wordpress_pv.metadata[0].name    
    storage_class_name = kubernetes_storage_class.default_gp3.metadata[0].name
#    storage_class_name = "manual"
  }
}


resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  depends_on = [kubernetes_storage_class.default_gp3]
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
    volume_name        = kubernetes_persistent_volume.mysql_pv.metadata[0].name    
    storage_class_name = kubernetes_storage_class.default_gp3.metadata[0].name
#    storage_class_name = "manual"
  }
}

## Uncomment for local/predefined storage
## As well as storage_class_name = "manual" in PVC

#resource "kubernetes_persistent_volume" "wordpress_pv" {
#  metadata {
#    name      = "wordpress-pv"
#    labels = {
#        app = "wordpress"
#        function = "wordpress_data_storage"
#    }
#  }
#  spec {
#    capacity = {
#      storage = var.wordpress_storage
#    }
#    access_modes = ["ReadWriteOnce"]
#    persistent_volume_reclaim_policy  = "Retain"
#    storage_class_name                = "manual"
#    persistent_volume_source {
#      host_path {
#        path = var.wordpress_host_path
#      }
#    }
#  }
#}


## Uncomment for local/predefined storage

#resource "kubernetes_persistent_volume" "mysql_pv" {
#  metadata {
#    name = "mysql-pv"
#    labels = {
#        app = "mysql"
#        function = "mysql_database_storage"
#    }
#  }
#  spec {
#    capacity = {
#      storage = var.mysql_storage
#    }
#    access_modes = ["ReadWriteOnce"]
#    persistent_volume_reclaim_policy  = "Retain"
#    storage_class_name                = "manual"
#    persistent_volume_source {
#      host_path {
#        path = var.mysql_host_path
#      }
#    }
#  }
#}



