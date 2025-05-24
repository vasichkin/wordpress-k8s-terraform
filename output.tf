output "info" {
  depends_on = [kubernetes_ingress_v1.wordpress]
  value = "For initial Wordpress setup, open port 30080 in SecurityGroups and visit <cluster_public_ip>:30080\n Setup wordpress, set address site to your public domain (or public IP address)"
}
