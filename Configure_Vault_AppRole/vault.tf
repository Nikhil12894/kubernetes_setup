variable "vault_token" {
  type      = string
  sensitive = true
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = var.vault_token
}

# Enable the AppRole auth method
resource "vault_auth_backend" "approle" {
  type = "approle"
}

# Define a secret in Vault
resource "vault_generic_secret" "my_secret" {
  path      = "secret/k8s_app/mysecret"
  data_json = <<EOT
{
  "username": "admin",
  "password": "secretpassword"
}
EOT
}

# Define a policy for accessing the secret
resource "vault_policy" "app_policy" {
  name   = "app-policy"
  policy = <<EOT
path "secret/data/k8s_app/*" {
  capabilities = ["read"]
}
EOT
}

# Define an AppRole with the policy attached
resource "vault_approle_auth_backend_role" "app_role" {
  role_name     = "app-role"
  token_ttl     = 600
  token_max_ttl = 1200

  token_policies = [vault_policy.app_policy.name]
}

# Output the role_id for the AppRole
output "approle_role_id" {
  value     = vault_approle_auth_backend_role.app_role.role_id
  sensitive = true
}

# Generate a secret_id for the AppRole
resource "vault_approle_auth_backend_role_secret_id" "app_role_secret_id" {
  role_name = vault_approle_auth_backend_role.app_role.role_name
}

# Output the secret_id for the AppRole
output "approle_secret_id" {
  value     = vault_approle_auth_backend_role_secret_id.app_role_secret_id.secret_id
  sensitive = true
}

# Define a Kubernetes Secret to store the Vault secret_id
resource "kubernetes_secret" "vault-springboot-secret" {
  metadata {
    name = "vault-springboot-secret"
  }

  data = {
    VAULT_KEY = vault_approle_auth_backend_role_secret_id.app_role_secret_id.secret_id
  }
}

# Define a Kubernetes ConfigMap to store the Vault configuration
resource "kubernetes_config_map" "cluster-config" {
  metadata {
    name = "cluster-config"
  }

  data = {
    ACTIVE_PROFILE = "k8s"
    VAULT_ENABLED  = "true"
    VAULT_BACKEND  = "secret"
    VAULT_URL      = "http://vault.vault:8200"
    VAULT_ROLE_ID  = vault_approle_auth_backend_role.app_role.role_id
  }
}
