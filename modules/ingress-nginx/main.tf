resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = var.nginx-version
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  values = [templatefile("modules/ingress-nginx/values.yaml", {})]
  
}