package com.burgerbuilder.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**").allowedOrigins(getAllowedOrigin()).allowedMethods("GET", "POST", "PUT", "DELETE");
    }

    private String getAllowedOrigin() {
        // Change 'production' to your method of determining the environment
        String environment = System.getenv("APP_ENV");
        if ("production".equals(environment)) {
            return "https://20.230.242.199";
        }
        return "http://localhost:3000";
    }
}
