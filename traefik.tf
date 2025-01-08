#traefik deployment

resource "kubernetes_namespace" "traefik" {
    metadata {
      name = "traefik"
    }
}

resource "helm_release" "traefik" {
  depends_on = [ kubernetes_namespace.traefik ]

  name = "traefik"
  namespace = "traefik"

  chart = "traefik"

  repository = "https://helm.traefik.io/traefik"

  set {
    name = "ingressClass.enabled"
    value = "true"
  }

  set {
    name = "ingressClass.isDefaultClass"
    value = "true"
  }

    //redirect to websecure aka https 
  set {
    name = "ports.web.redirectTo.port"
    value = "websecure"
  }
    // make sure tls is enabled on websecure to make it https
  set {
    name = "ports.websecure.tls.enabled"
    value = "true"
  }
}

