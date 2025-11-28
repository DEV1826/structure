package com.NND.tech.Structure_Backend.config;

import com.NND.tech.Structure_Backend.Repository.UserRepository;
import com.NND.tech.Structure_Backend.model.entity.RoleType;
import com.NND.tech.Structure_Backend.model.entity.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.superadmin.email}")
    private String superAdminEmail;

    @Value("${app.superadmin.password}")
    private String superAdminPassword;

    public DataInitializer(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        // 🔍 Vérifie les utilisateurs avec un rôle mal formé
        userRepository.findAll().forEach(user -> {
            try {
                RoleType correctedRole = RoleType.valueOf(user.getRole().name().toUpperCase());
                user.setRole(correctedRole);
            } catch (IllegalArgumentException | NullPointerException e) {
                System.err.println("Rôle invalide détecté pour l'utilisateur : " + user.getEmail());
                user.setRole(RoleType.USER); // Rôle par défaut
            }
        });

        // 🔄 Sauvegarde les modifications
        userRepository.flush();

        // 👤 Création du SUPER_ADMIN si absent
        Optional<User> existingSuperAdmin = userRepository.findByEmail(superAdminEmail);

        if (existingSuperAdmin.isEmpty()) {
            User superAdmin = User.builder()
                    .firstName("Super")
                    .lastName("Admin")
                    .email(superAdminEmail)
                    .password(passwordEncoder.encode(superAdminPassword))
                    .role(RoleType.SUPER_ADMIN)
                    .active(true)
                    .build();
            userRepository.save(superAdmin);
            System.out.println("✅ Super Admin créé avec succès !");
        } else {
            // Vérifie si le mot de passe du SUPER_ADMIN a changé
            User superAdmin = existingSuperAdmin.get();
            if (!passwordEncoder.matches(superAdminPassword, superAdmin.getPassword())) {
                superAdmin.setPassword(passwordEncoder.encode(superAdminPassword));
                userRepository.save(superAdmin);
                System.out.println("🔑 Mot de passe du Super Admin mis à jour !");
            }
        }
    }
}
