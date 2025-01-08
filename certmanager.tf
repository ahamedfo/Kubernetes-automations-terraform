resource "kubernetes_namespace" "certmanager" {
  
  metadata {
    name = "certmanager"
  }
}

resource "helm_release" "certmanager" {
  depends_on = [ kubernetes_namespace.certmanager ]

  name = "certmanager"
  namespace = "certmanager"

  chart = "cert-manager"
  repository = "https://charts.jetstack.io"

  set {
    name = "crds.enabled"
    value = "true"
  }
}

resource "time_sleep" "wait_for_certmanager" {
  depends_on = [ helm_release.certmanager ]
    //Without waiting sometimes terraform does not create the dependency object fast enough so we give it a wait duration
  create_duration = "10s"
}

