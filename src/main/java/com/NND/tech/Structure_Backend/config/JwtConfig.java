package com.NND.tech.Structure_Backend.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JwtConfig {

    @Bean
    @ConditionalOnProperty(name = "security.jwt.enabled", havingValue = "true", matchIfMissing = false)
    public JwtService jwtService() {
        return new JwtService("default-secret-key-1234567890-1234567890-1234567890", 86400000);
    }
}
