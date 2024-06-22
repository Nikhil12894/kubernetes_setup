# About This Project

This project is demonstrate importing of project configuration from **VAULT**.

I have used vault deployed on kubernetes cluster and configured *APPROLE*

### Vault Config

```properties

artifact.name=vault_demo
spring.profiles.active=${SPRING_PROFILES_ACTIVE:local}
spring.cloud.vault.application-name=${artifact.name}
spring.cloud.vault.enabled=${VAULT_ENABLED:false}
spring.cloud.vault.kv.enabled=true
spring.cloud.vault.kv.backend=${VAULT_BACKEND:secret}
spring.cloud.vault.uri=${VAULT_URL:http://localhost:8200}
spring.cloud.vault.authentication=APPROLE
spring.cloud.vault.app-role.role-id=<Role_ID>
spring.cloud.vault.app-role.secret-id=${VAULT_KEY:<vault_key>}
spring.cloud.vault.read-timeout=15000
spring.cloud.vault.connection-timeout=5000
spring.config.import=optional:file:config/local.properties,optional:vault://${spring.cloud.vault.kv.backend}/k8s_app/${spring.cloud.vault.application-name}/${spring.profiles.active}


```


- For Creating Kubernetes manifest file I used dekorate dependency then used that
to deploy it on kubernetes cluster.

    ```xml
    <dependency>
        <groupId>io.dekorate</groupId>
        <artifactId>kubernetes-spring-starter</artifactId>
        <version>4.1.3</version>
        <optional>true</optional>
    </dependency>
    ```


# Push Docker build to GitHub
- Create a personal token
    The username to the registry is the same as your GitHub username. For the password you need to create a GitHub personal token.

    When creating the personal token, you need to select at least the following scopes:

    - write:packages
    - read:packages
    - delete:packages
    - repo if your repository is private; if public, do not select
Once you create the token, note it down.
You can make sure that your token is valid by using it as a password on your local workstation with the Docker command:

``` sh
docker login ghcr.io --username github-account
[Paste your GitHub token on this prompt]
```


#### Create Github Image pull secrete

- convert github token to base64 **with github username**
```sh
 echo -n "your-github-username:your-personal-access-token" | base64
```
- then use it in below script

```sh
 echo -n  '{"auths":{"ghcr.io":{"auth":"<token from above command>"}}}' | base64
```
- now pest it in secrete file with key .dockerconfig
    ```yml
    kind: Secret
    type: kubernetes.io/dockerconfigjson
    apiVersion: v1
    metadata:
    name: <secrete_name>
    labels:
        app: <label>
    data:
    .dockerconfigjson: <Base64 code from abaove stape>
    ```


#### Deploy My App To Kubernetes

- first create vault secrete for **secret-id**

    ```sh
        kubectl create secret generic <secrete_name> --from-literal=SECRET_KEY_NAME='secrete_value'
    ```
- or

    ```yml
    apiVersion: v1
    data:
        SECRET_KEY_NAME: <base64 encoded value>
    kind: Secret
    metadata:
        name: <secrete_name>
        namespace: default
    type: Opaque
    ```
- Add config map

    ```yml
    apiVersion: v1
    kind: ConfigMap
    metadata:
    name: cluster-config
    labels:
        app: demo
        tier: springboot
    data:
    ACTIVE_PROFILE: k8s
    VAULT_ENABLED: "true"
    VAULT_BACKEND: secret
    VAULT_URL: http://vault.vault:8200
    VAULT_ROLE_ID: c8fc7a81-eb38-52f6-4996-2b8c700f18ab
    ```

- now run below command and use kubernetes.yml to deploy the app to kubernetes
	```sh
	./mvnw clean package
	```
