#!/bin/sh

# Replace with your actual values
VAULT_ADDR="http://127.0.0.1:8200"
ROLE_ID="87db7cc5-1e4b-3058-1614-266ac682146c"
SECRET_ID="c903c839-d89a-e784-b746-3924a8511efc"

# Authenticate with Vault using AppRole
VAULT_TOKEN=$(curl --request POST --data '{"role_id": "'"$ROLE_ID"'", "secret_id": "'"$SECRET_ID"'"}' $VAULT_ADDR/v1/auth/approle/login | jq -r .auth.client_token)

# Read a secret from Vault
SECRET=$(curl --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/secret/data/k8s_app/mysecret | jq -r .data.data)
echo "My secret value is: $SECRET"
