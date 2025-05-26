package com.example.listingService.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenAPIConfig {
    @Bean
    public OpenAPI listingMicroserviceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Listing and reservations API")
                        .description("API for managing listings and reservations")
                        .version("1.0"));
    }
}