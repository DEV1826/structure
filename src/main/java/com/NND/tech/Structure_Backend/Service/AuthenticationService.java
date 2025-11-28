package com.NND.tech.Structure_Backend.Service;

import com.NND.tech.Structure_Backend.DTO.AuthenticationRequest;
import com.NND.tech.Structure_Backend.DTO.AuthenticationResponse;
import com.NND.tech.Structure_Backend.DTO.RegisterRequest;
import com.NND.tech.Structure_Backend.config.JwtService;
import com.NND.tech.Structure_Backend.model.entity.RoleType;
import com.NND.tech.Structure_Backend.model.entity.User;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.NND.tech.Structure_Backend.Repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.util.logging.Level;
import java.util.logging.Logger;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private static final Logger logger = Logger.getLogger(AuthenticationService.class.getName());

    private final UserRepository userRepository;
    private final StructureRepository structureRepository;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final PasswordEncoder passwordEncoder;

    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        logger.info("=== Début de l'authentification pour: " + request.getEmail() + " ===");

        try {
            // Authentification Spring Security
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );

            // Récupération de l'utilisateur
            User user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new BadCredentialsException("Email ou mot de passe incorrect"));

            // Vérifier si l'utilisateur est actif
            if (!user.isActive()) {
                throw new BadCredentialsException("Ce compte a été désactivé");
            }

            // Générer le token (JwtService attend un UserDetails)
            UserDetails springUser = org.springframework.security.core.userdetails.User
                    .withUsername(user.getEmail())
                    .password(user.getPassword())
                    .authorities(user.getRole().name())
                    .build();
            var jwtToken = jwtService.generateToken(springUser);

            logger.info("Authentification réussie pour: " + request.getEmail());

            return new AuthenticationResponse(
                    jwtToken,
                    user.getEmail(),
                    user.getRole().name(),
                    jwtService.getExpirationTime()
            );

        } catch (BadCredentialsException e) {
            logger.severe("Identifiants incorrects pour: " + request.getEmail());
            throw new BadCredentialsException("Identifiants incorrects");
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Erreur complète lors de l'authentification", e);
            throw new RuntimeException("Erreur lors de l'authentification", e);
        }
    }

    @Transactional
    public AuthenticationResponse register(RegisterRequest request) {
        logger.info("=== Début de l'enregistrement pour: " + request.getEmail() + " ===");

        // Vérifier si l'utilisateur existe déjà
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Un utilisateur avec cet email existe déjà");
        }

        try {
            // Créer un nouvel utilisateur avec le builder
            User user = User.builder()
                    .email(request.getEmail())
                    .password(passwordEncoder.encode(request.getPassword()))
                    .firstName(request.getFirstName())
                    .lastName(request.getLastName())
                    .phone(request.getTelephone())
                    .role(RoleType.USER) // Par défaut, on crée un utilisateur standard
                    .active(true)
                    .build();

            // Gestion du rôle
            String roleStr = request.getRole();
            if (roleStr != null) {
                roleStr = roleStr.trim().replace("-", "_").replace(" ", "_").toUpperCase();
                // Recherche insensible à la casse
                RoleType found = null;
                for (RoleType type : RoleType.values()) {
                    if (type.name().equalsIgnoreCase(roleStr)) {
                        found = type;
                        break;
                    }
                }
                if (found == null) {
                    throw new IllegalArgumentException("Rôle invalide: " + roleStr);
                }
                user.setRole(found);
            } else {
                throw new IllegalArgumentException("Le champ 'role' est requis");
            }

            // Association de structure non gérée ici (RegisterRequest ne contient pas de structureId)

            User savedUser = userRepository.save(user);

            // Générer le token après l'enregistrement
            UserDetails springUser = org.springframework.security.core.userdetails.User
                    .withUsername(savedUser.getEmail())
                    .password(savedUser.getPassword())
                    .authorities(savedUser.getRole().name())
                    .build();
            var jwtToken = jwtService.generateToken(springUser);

            logger.info("Utilisateur enregistré avec succès: " + savedUser.getEmail());

            return new AuthenticationResponse(
                    jwtToken,
                    savedUser.getEmail(),
                    savedUser.getRole().name(),
                    jwtService.getExpirationTime()
            );

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Erreur lors de l'enregistrement", e);
            throw new RuntimeException("Erreur lors de l'enregistrement: " + e.getMessage(), e);
        }
    }

    private void validateRegisterRequest(RegisterRequest request) {
        if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("L'email est requis");
        }

        if (request.getPassword() == null || request.getPassword().length() < 6) {
            throw new IllegalArgumentException("Le mot de passe doit contenir au moins 6 caractères");
        }

        if (request.getFirstName() == null || request.getFirstName().trim().isEmpty()) {
            throw new IllegalArgumentException("Le prénom est requis");
        }

        if (request.getLastName() == null || request.getLastName().trim().isEmpty()) {
            throw new IllegalArgumentException("Le nom est requis");
        }

        if (!request.getEmail().contains("@") || !request.getEmail().contains(".")) {
            throw new IllegalArgumentException("Format d'email invalide");
        }
    }
}
