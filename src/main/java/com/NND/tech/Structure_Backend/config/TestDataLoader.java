package com.NND.tech.Structure_Backend.config;

import com.NND.tech.Structure_Backend.model.entity.RoleType;
import com.NND.tech.Structure_Backend.model.entity.ServiceEntity;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.model.entity.User;
import com.NND.tech.Structure_Backend.repository.ServiceRepository;
import com.NND.tech.Structure_Backend.repository.StructureRepository;
import com.NND.tech.Structure_Backend.repository.UserRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.boot.CommandLineRunner;

import java.math.BigDecimal;

@Configuration
@Profile("test")
public class TestDataLoader {

    @Bean
    CommandLineRunner loadTestData(
            StructureRepository structureRepository,
            UserRepository userRepository,
            ServiceRepository serviceRepository,
            PasswordEncoder passwordEncoder
    ) {
        return args -> {
            if (structureRepository.count() == 0) {
                Structure structure = new Structure();
                structure.setName("Test Structure");
                structure.setAddress("123 Test St");
                structure.setActive(true);
                structure = structureRepository.save(structure);

                if (userRepository.count() == 0) {
                    User user = new User();
                    user.setFirstName("John");
                    user.setLastName("Doe");
                    user.setEmail("john.doe@example.com");
                    user.setPassword(passwordEncoder.encode("password123"));
                    user.setRole(RoleType.ADMIN);
                    user.setActive(true);
                    user.setStructure(structure);
                    userRepository.save(user);
                }

                if (serviceRepository.count() == 0) {
                    ServiceEntity service = new ServiceEntity();
                    service.setName("Test Service");
                    service.setCategory("General");
                    service.setDescription("Test Description");
                    service.setPrice(new BigDecimal("100.00"));
                    service.setDuration(60);
                    service.setActive(true);
                    service.setStructure(structure);
                    serviceRepository.save(service);
                }
            }
        };
    }
}
