output "vault_namespace" {
  value = kubernetes_namespace.vault.metadata[0].name
}

output "argocd_namespace" {
  value = kubernetes_namespace.argocd.metadata[0].name
}
