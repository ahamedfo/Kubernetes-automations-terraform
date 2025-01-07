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

  repository = ""
}