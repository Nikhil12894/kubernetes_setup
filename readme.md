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
    minikube delete --all
    
    ```

#### First Apply terraform from [Install_Argocd_Vault](./Install_Argocd_Vault/)

#### Second apply terraform from [Configure_Vault_AppRole](./Configure_Vault_AppRole/)

#### Then to print app role and secrete id run command fro [this file](./Configure_Vault_AppRole/readme.md)

---


### For Spring Boot Setup Detail Please Reffere [Vault_demo code](./vault_demo/)
- apply [dockerconfig](vault_demo/k8s/dockerconfigjson.yaml)
#### Create Github Image pull secrete
- convert github token to base64 **with github username**
```sh
 echo -n "your-github-username:your-personal-access-token" | base64
```
- then use it in below script

```sh
 echo -n  '{"auths":{"ghcr.io":{"auth":"<token from above command>"}}}' | base64
```
- now create a file *imagepullsecratefile.yml* or what ever yoy want
- now past it in secrete file with key .dockerconfig
    ```yml
    kind: Secret
    type: kubernetes.io/dockerconfigjson
    apiVersion: v1
    metadata:
    name: <secrete_name>
    labels:
        app: <label>
    data:
    .dockerconfigjson: <Base64 code from above step>
    ```
    ```sh
    kubectl apply -f <imagepullsecratefile.yml>
    ```
- add GitHub repo in ArgoCd
![Repo Setup](./images/add_repo_in_argocd.png)
- add the app in argocd
![Repo Setup](./images/add_app_in_argocd.png)


