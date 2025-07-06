package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.DTO.AuthenticationRequest;
import com.NND.tech.Structure_Backend.DTO.AuthenticationResponse;
import com.NND.tech.Structure_Backend.DTO.RegisterRequest;
import com.NND.tech.Structure_Backend.Service.AuthenticationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationService service;

    public AuthController(AuthenticationService service) {
        this.service = service;
    }

    /**
     * Endpoint pour créer un nouvel administrateur.
     * Seul un SUPER_ADMIN peut effectuer cette action.
     */
    @PostMapping("/register-admin")
    @PreAuthorize("hasAuthority('SUPER_ADMIN')")
    public ResponseEntity<AuthenticationResponse> registerAdmin(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(service.registerAdmin(request));
    }

    /**
     * Endpoint pour authentifier un utilisateur (Admin ou Super Admin).
     */
    @PostMapping("/login")
    public ResponseEntity<AuthenticationResponse> authenticate(@RequestBody AuthenticationRequest request) {
        return ResponseEntity.ok(service.authenticate(request));
    }
}
