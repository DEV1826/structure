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
        logger.info("Tentative de connexion pour : " + request.getIdentifier());

        // 1. Recherche de l'utilisateur en base
        User user = userRepository.findByEmail(request.getIdentifier())
                .or(() -> userRepository.findByUsername(request.getIdentifier()))
                .orElseThrow(() -> {
                    logger.warning("Utilisateur non trouvé en base pour : " + request.getIdentifier());
                    return new BadCredentialsException("Identifiants incorrects");
                });

        logger.info("Utilisateur trouvé : " + user.getEmail() + " avec rôle : " + user.getRole());

        // 2. Vérification du statut
        if (!user.isActive()) {
            logger.warning("Compte désactivé pour : " + user.getEmail());
            throw new BadCredentialsException("Ce compte a été désactivé.");
        }

        // 3. Authentification Spring Security
        // C'est ici que le mot de passe est vérifié avec le PasswordEncoder
        try {
            logger.info("Appel à authenticationManager.authenticate pour : " + user.getEmail());
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            user.getEmail(),
                            request.getPassword()
                    )
            );
            logger.info("Authentification réussie via le Manager pour : " + user.getEmail());
        } catch (BadCredentialsException e) {
            logger.warning("Échec d'authentification pour : " + request.getIdentifier());
            throw new BadCredentialsException("Identifiants incorrects");
        }

        // 4. Génération du Token
        // On utilise directement l'objet 'user' car il implémente UserDetails
        var jwtToken = jwtService.generateToken(user);

        return AuthenticationResponse.builder()
                .token(jwtToken)
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .role(user.getRole())
                .structureId(user.getStructure() != null ? user.getStructure().getId() : null)
                .firstLogin(user.isFirstLogin())
                .expiresIn(jwtService.getExpirationTime())
                .build();
    }

    @Transactional
    public AuthenticationResponse register(RegisterRequest request) {
        logger.info("Enregistrement : " + request.getEmail());

        validateRegisterRequest(request);

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Un utilisateur avec cet email existe déjà");
        }

        try {
            // Création de l'entité User
            User user = User.builder()
                    .email(request.getEmail())
                    .username(request.getEmail())
                    .password(passwordEncoder.encode(request.getPassword())) // Hachage crucial
                    .firstName(request.getFirstName())
                    .lastName(request.getLastName())
                    .phone(request.getTelephone())
                    .active(true)
                    .firstLogin(true)
                    .build();

            // Gestion propre du rôle
            if (request.getRole() != null) {
                try {
                    RoleType role = RoleType.valueOf(request.getRole().trim().toUpperCase().replace("-", "_"));
                    user.setRole(role);
                } catch (IllegalArgumentException e) {
                    user.setRole(RoleType.USER); // Rôle par défaut si erreur
                }
            } else {
                user.setRole(RoleType.USER);
            }

            User savedUser = userRepository.save(user);

            // Génération du token directement à partir de l'utilisateur sauvegardé
            var jwtToken = jwtService.generateToken(savedUser);

            return AuthenticationResponse.builder()
                    .token(jwtToken)
                    .id(savedUser.getId())
                    .email(savedUser.getEmail())
                    .username(savedUser.getUsername())
                    .firstName(savedUser.getFirstName())
                    .lastName(savedUser.getLastName())
                    .role(savedUser.getRole())
                    .structureId(savedUser.getStructure() != null ? savedUser.getStructure().getId() : null)
                    .firstLogin(savedUser.isFirstLogin())
                    .expiresIn(jwtService.getExpirationTime())
                    .build();

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Erreur lors de l'enregistrement", e);
            throw new RuntimeException("Erreur serveur lors de l'enregistrement");
        }
    }

    private void validateRegisterRequest(RegisterRequest request) {
        if (request.getEmail() == null || !request.getEmail().contains("@")) {
            throw new IllegalArgumentException("Email invalide");
        }
        if (request.getPassword() == null || request.getPassword().length() < 6) {
            throw new IllegalArgumentException("Mot de passe trop court (min 6 caractères)");
        }
    }
}