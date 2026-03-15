package com.NND.tech.Structure_Backend;

import com.NND.tech.Structure_Backend.Repository.UserRepository;
import com.NND.tech.Structure_Backend.model.entity.RoleType;
import com.NND.tech.Structure_Backend.model.entity.User;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
public class StructureBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(StructureBackendApplication.class, args);
	}

	@Bean
	public CommandLineRunner initData(UserRepository userRepository, PasswordEncoder passwordEncoder) {
		return args -> {
			// Création de l'admin s'il n'existe pas
			if (!userRepository.existsByEmail("admin1@structureA.com")) {
				System.out.println("Création du compte admin : admin1@structureA.com");
				User admin = User.builder()
						.email("admin1@structureA.com")
						.username("admin1")
						.password(passwordEncoder.encode("password"))
						.firstName("Admin")
						.lastName("One")
						.role(RoleType.ADMIN)
						.active(true)
						.firstLogin(false)
						.build();
				userRepository.save(admin);
			}

			// Création du super admin s'il n'existe pas
			if (!userRepository.existsByEmail("superadmin@example.com")) {
				System.out.println("Création du compte superadmin : superadmin@example.com");
				User superAdmin = User.builder()
						.email("superadmin@example.com")
						.username("superadmin")
						.password(passwordEncoder.encode("password"))
						.firstName("Super")
						.lastName("Admin")
						.role(RoleType.SUPER_ADMIN)
						.active(true)
						.firstLogin(false)
						.build();
				userRepository.save(superAdmin);
			}

			System.out.println("Vérification des comptes de test terminée.");
		};
	}
}
