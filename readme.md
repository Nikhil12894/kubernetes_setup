- **Argo CD:** Forward the port and access it via browser:
    ```sh
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```
    Access Argo CD at https://localhost:8080.

- **Vault:** Forward the port and access it via browser:
    ```sh
    kubectl port-forward svc/vault -n vault 8200:8200
    ```
    Access Vault at http://localhost:8200.

1. **Argo CD Login:** The initial password for the admin account is the name of the Argo CD server pod:
    ```sh
    kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name
    ```
2. **Vault Initialization and Unsealing:** Initialize and unseal Vault:

    ```sh
    vault operator init
    vault operator unseal <Unseal Key 1>
    vault operator unseal <Unseal Key 2>
    vault operator unseal <Unseal Key 3>
    ```

- get Argocd password

    ```sh
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```


- For getting vault password see the vault logs

- **Delete Kubernetes:**

    ```
    kube delete --all
    
    ```

#### First Apply terraform from [Install_Argocd_Vault](./Install_Argocd_Vault/)

#### Second apply terraform from [Configure_Vault_AppRole](./Configure_Vault_AppRole/)

#### Then to print app role and secrate id run command fro [this file](./Configure_Vault_AppRole/readme.md)

