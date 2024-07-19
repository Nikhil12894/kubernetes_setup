package com.nk.vault_demo;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.ExternalDocumentation;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;

@Configuration
public class SpringDocConfig {
//     @Value("${server.servlet.context-path}") private String hostUrl;
    @Bean
    public OpenAPI api() {
        Server server = new Server();
        server.setUrl("/");
        return new OpenAPI()
                .servers(List.of(server))
                // .components(new Components().addSecuritySchemes("bearer-key", new SecurityScheme().type(SecurityScheme.Type.HTTP).scheme("bearer").bearerFormat("JWT")))
                .info(new Info().title("Demo::Spring Boot with Vault")
                        .version("v1"))
                .externalDocs(new ExternalDocumentation()
                        .description("vault_demo GitHub Repository")
                        .url("https://github.com/Nikhil12894/kubernetes_setup/tree/main/vault_demo"));
    }
}