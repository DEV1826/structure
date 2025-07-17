package com.NND.tech.Structure_Backend.Service;

import com.NND.tech.Structure_Backend.DTO.AuthenticationRequest;
import com.NND.tech.Structure_Backend.DTO.AuthenticationResponse;
import com.NND.tech.Structure_Backend.DTO.RegisterRequest;
import com.NND.tech.Structure_Backend.Repository.UtilisateurRepository;
import com.NND.tech.Structure_Backend.config.JwtService;
import com.NND.tech.Structure_Backend.entities.Utilisateur;
import com.NND.tech.Structure_Backend.entities.RoleType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

@Service
public class AuthenticationService {

    private static final Logger logger = Logger.getLogger(AuthenticationService.class.getName());

    private final UtilisateurRepository repository;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final PasswordEncoder passwordEncoder;

    public AuthenticationService(UtilisateurRepository repository,
                                 JwtService jwtService,
                                 AuthenticationManager authenticationManager,
                                 PasswordEncoder passwordEncoder) {
        this.repository = repository;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.passwordEncoder = passwordEncoder;
    }

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
            var user = repository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            // Générer le token
            var jwtToken = jwtService.generateToken(user);

            logger.info("Authentification réussie pour: " + request.getEmail());

            return new AuthenticationResponse(
                    jwtToken,
                    user.getEmail(),
                    user.getRole().name(),
                    3600L // durée d'expiration fictive, à remplacer si nécessaire
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

        // Validation des données d'entrée
        validateRegisterRequest(request);

        // Vérifier si l'utilisateur existe déjà
        Optional<Utilisateur> existingUser = repository.findByEmail(request.getEmail());
        if (existingUser.isPresent()) {
            throw new IllegalArgumentException("Un utilisateur avec cet email existe déjà");
        }

        try {
            // Créer un nouvel utilisateur
            var user = new Utilisateur();
            user.setEmail(request.getEmail());
            user.setMotDePasse(passwordEncoder.encode(request.getPassword()));
            user.setNom(request.getLastName());
            user.setPrenom(request.getFirstName());
            user.setTelephone(request.getTelephone());

            // Format correct du rôle
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
        throw new IllegalArgumentException("Rôle invalide : " + request.getRole());
    }
    user.setRole(found);
} else {
    throw new IllegalArgumentException("Le champ 'role' est requis");
}

            repository.save(user);

            // Générer le token JWT
            var jwtToken = jwtService.generateToken(user);

            logger.info("Enregistrement réussi pour: " + request.getEmail());

            return new AuthenticationResponse(
                    jwtToken,
                    user.getEmail(),
                    user.getRole().name(),
                    3600L // durée fictive
            );

        } catch (IllegalArgumentException e) {
            logger.severe("Rôle invalide : " + request.getRole());
            throw new RuntimeException("Rôle invalide : " + request.getRole(), e);
        } catch (Exception e) {
            logger.severe("Erreur lors de l'enregistrement: " + e.getMessage());
            throw new RuntimeException("Erreur lors de l'enregistrement", e);
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
