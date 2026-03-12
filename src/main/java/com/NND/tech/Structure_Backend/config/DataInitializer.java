package com.NND.tech.Structure_Backend.config;

import com.NND.tech.Structure_Backend.Repository.UserRepository;
import com.NND.tech.Structure_Backend.model.entity.RoleType;
import com.NND.tech.Structure_Backend.model.entity.User;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // On peut garder des valeurs par défaut au cas où le fichier properties est vide
    private static final String DEFAULT_ADMIN_EMAIL = "admin@structure.cm";
    private static final String DEFAULT_ADMIN_USER = "superadmin";

    public DataInitializer(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        // 1. Nettoyage des rôles (Ta logique actuelle est conservée et améliorée)
        userRepository.findAll().forEach(user -> {
            if (user.getRole() == null) {
                user.setRole(RoleType.USER); // Rôle CLIENT/USER par défaut
                userRepository.save(user);
            }
        });

        // 2. Création automatique du premier Super-Admin si la table est vide
        if (userRepository.count() == 0) {
            User superAdmin = User.builder()
                    .username(DEFAULT_ADMIN_USER)
                    .firstName("Super")
                    .lastName("Admin")
                    .email(DEFAULT_ADMIN_EMAIL)
                    .password(passwordEncoder.encode("admin123")) // Mot de passe temporaire
                    .role(RoleType.SUPER_ADMIN)
                    .active(true)
                    .firstLogin(true) // Marqueur pour forcer le changement au profil [cite: 25]
                    .build();

            userRepository.save(superAdmin);
            System.out.println("🚀 INITIALISATION : Compte Super-Admin créé (superadmin / admin123)");
        }
    }
}