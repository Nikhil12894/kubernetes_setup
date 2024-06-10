package com.nk.vault_demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.dekorate.docker.annotation.DockerBuild;
import io.dekorate.kubernetes.annotation.Env;
import io.dekorate.kubernetes.annotation.KubernetesApplication;
import io.dekorate.kubernetes.annotation.Probe;

@SpringBootApplication
@KubernetesApplication( // will generate a kubernetes manifest file
  name = "vault-demo",
  livenessProbe = @Probe(httpActionPath="/actuator/health/liveness"),
  readinessProbe = @Probe(httpActionPath="/actuator/health/readiness"),
  envVars = {
    @Env(
      name = "SPRING_PROFILES_ACTIVE",
      configmap = "cluster-config",
      value = "ACTIVE_PROFILE"
    ),
    @Env(
      name = "VAULT_ENABLED",
      configmap = "cluster-config",
      value = "VAULT_ENABLED"
    ),
    @Env(
      name = "VAULT_BACKEND",
      configmap = "cluster-config",
      value = "VAULT_BACKEND"
    ),
    @Env(
        name = "VAULT_URL",
        configmap = "cluster-config",
        value = "VAULT_URL"
      ),
    @Env(
        name = "VAULT_KEY",
        secret = "vault-springboot-secret",
        value = "VAULT_KEY"
      ),
    @Env(
      name = "VAULT_ROLE_ID",
      configmap = "cluster-config",
      value = "VAULT_ROLE_ID"
    )
  },
  imagePullSecrets = { "dockerconfigjson-github-com" }
  // serviceAccount="app-sa"
  
)
@DockerBuild( // will use this registry and image in generated kubernetes manifest file
  registry = "ghcr.io/nikhil12894",
  image = "ghcr.io/nikhil12894/vault-demo:latest"
)
public class VaultDemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(VaultDemoApplication.class, args);
	}

}


@RestController
@RequestMapping("/api/v1")
class DemoController{

	@Value("${message}")
	private String message;
	@GetMapping
	public String getVaultSecrete(){
		return message;
	}
}
