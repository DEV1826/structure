package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.DTO.AuthenticationRequest;
import com.NND.tech.Structure_Backend.DTO.AuthenticationResponse;
import com.NND.tech.Structure_Backend.DTO.RegisterRequest;
import com.NND.tech.Structure_Backend.Service.AuthenticationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "Endpoints d'authentification")
public class AuthController {

    private final AuthenticationService authenticationService;

    public AuthController(AuthenticationService authenticationService) {
        this.authenticationService = authenticationService;
    }

    @PostMapping("/login")
    @Operation(
            summary = "Connexion utilisateur",
            description = "Authentifie un utilisateur (Admin ou Super Admin) et retourne un token JWT"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Connexion réussie"),
            @ApiResponse(responseCode = "401", description = "Identifiants invalides ")
    })
    public ResponseEntity<AuthenticationResponse> login(@RequestBody AuthenticationRequest request) {
        // Cette méthode unique gère maintenant l'authentification
        return ResponseEntity.ok(authenticationService.authenticate(request));
    }

    @PostMapping("/register")
    @Operation(
            summary = "Inscription utilisateur",
            description = "Crée un nouveau compte utilisateur (Client par défaut) et retourne un token JWT"
    )
    public ResponseEntity<AuthenticationResponse> register(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authenticationService.register(request));
    }


    @GetMapping("/me")
    @Operation(summary = "Profil utilisateur connecté", description = "Retourne les infos de l'utilisateur authentifié via son JWT")
    public ResponseEntity<AuthenticationResponse> getMe(
            @AuthenticationPrincipal com.NND.tech.Structure_Backend.model.entity.User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }
        AuthenticationResponse response = AuthenticationResponse.builder()
                .id(currentUser.getId())
                .email(currentUser.getEmail())
                .username(currentUser.getUsername())
                .firstName(currentUser.getFirstName())
                .lastName(currentUser.getLastName())
                .role(currentUser.getRole())
                .structureId(currentUser.getStructure() != null ? currentUser.getStructure().getId() : null)
                .firstLogin(currentUser.isFirstLogin())
                .build();
        return ResponseEntity.ok(response);
    }
}
