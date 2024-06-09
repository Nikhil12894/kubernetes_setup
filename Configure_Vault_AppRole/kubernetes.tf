resource "kubernetes_namespace" "other" {
  metadata {
    name = "other-namespace"
  }
}

resource "kubernetes_service_account" "default_sa" {
  metadata {
    name      = "app-sa"
    namespace = "default"
  }
}

resource "kubernetes_service_account" "other_sa" {
  metadata {
    name      = "app-sa"
    namespace = kubernetes_namespace.other.metadata[0].name
  }
}
