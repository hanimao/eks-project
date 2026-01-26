
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.14.1"
  create_namespace = true
  namespace = "ingress"

 values = [
    file("${path.module}/../../helm-values/nginx-ingress.yaml")
  ]
}
 
 resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  create_namespace = true
  namespace = "cert-manager"
 
  # cert manager uses custom resource to auto obtain and renew certs.  


  set = [
    {
      name  = "crds.enabled"
      value = "true"
    }
  ]
 values = [
    file("${path.module}/../../helm-values/cert-manager.yaml")
  ]
}
 



resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  create_namespace = true
  namespace = "external-dns"


 values = [
    file("${path.module}/../../helm-values/external-dns.yaml")
  ]
}


resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm/"
  chart      = "argo-cd"
  version    = "5.19.15"
  timeout    = "600"

  create_namespace = true
  namespace        = "argo-cd"

 values = [
    file("${path.module}/../../helm-values/argocd.yaml")
  ]

  depends_on = [helm_release.nginx_ingress, helm_release.cert_manager, helm_release.external_dns]
}

resource "helm_release" "prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "78.3.1"

  create_namespace = true
  namespace        = "monitoring"

 values = [
    file("${path.module}/../../helm-values/prometheus.yaml")
  ]


  depends_on = [helm_release.nginx_ingress, helm_release.cert_manager, helm_release.external_dns]
}