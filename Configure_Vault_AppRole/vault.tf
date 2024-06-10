resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_generic_secret" "my_secret" {
  path      = "secret/k8s_app/mysecret"
  data_json = <<EOT
{
  "username": "admin",
  "password": "secretpassword"
}
EOT
}

resource "vault_policy" "app_policy" {
  name   = "app-policy"
  policy = <<EOT
path "secret/data/k8s_app/*" {
  capabilities = ["read"]
}
EOT
}

resource "vault_approle_auth_backend_role" "app_role" {
  role_name     = "app-role"
  token_ttl     = 600
  token_max_ttl = 1200

  token_policies = [vault_policy.app_policy.name]
}

output "approle_role_id" {
  value     = vault_approle_auth_backend_role.app_role.role_id
  sensitive = true
}

resource "vault_approle_auth_backend_role_secret_id" "app_role_secret_id" {
  role_name = vault_approle_auth_backend_role.app_role.role_name
}

output "approle_secret_id" {
  value     = vault_approle_auth_backend_role_secret_id.app_role_secret_id.secret_id
  sensitive = true
}

# code to configure secrate and config map
resource "kubernetes_secret" "vault-springboot-secrate" {
  metadata {
    name = "vault-springboot-secrate"
  }

  data = {
    VAULT_KEY = "${vault_approle_auth_backend_role_secret_id.app_role_secret_id.secret_id}"
  }
}

resource "kubernetes_config_map" "cluster-config" {
  metadata {
    name = "cluster-config"
  }

  data = {
    ACTIVE_PROFILE = "k8s"
    VAULT_ENABLED  = "true"
    VAULT_BACKEND  = "secret"
    VAULT_URL      = "http://vault.vault:8200"
    VAULT_ROLE_ID = "${vault_approle_auth_backend_role.app_role.role_id}"
  }
}