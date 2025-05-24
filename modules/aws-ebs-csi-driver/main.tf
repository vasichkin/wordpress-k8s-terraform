resource "helm_release" "aws-ebs-csi-driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"

  values = [
    yamlencode({
      controller = {
        region           = var.aws_region
        extraVolumeTags  = var.aws_tags
      }
    })
  ]
}