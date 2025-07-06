package com.NND.tech.Structure_Backend.Service;

import com.NND.tech.Structure_Backend.DTO.AuthenticationRequest;
import com.NND.tech.Structure_Backend.DTO.AuthenticationResponse;
import com.NND.tech.Structure_Backend.DTO.RegisterRequest;
import com.NND.tech.Structure_Backend.Repository.UtilisateurRepository;
import com.NND.tech.Structure_Backend.config.JwtService;
import com.NND.tech.Structure_Backend.entities.Utilisateur;
import com.NND.tech.Structure_Backend.entities.RoleType;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

    @Service
    public class AuthenticationService {

        private final UtilisateurRepository repository;
        private final PasswordEncoder passwordEncoder;
        private final JwtService jwtService;
        private final AuthenticationManager authenticationManager;

        public AuthenticationService(UtilisateurRepository repository,
                                     PasswordEncoder passwordEncoder,
                                     JwtService jwtService,
                                     AuthenticationManager authenticationManager) {
            this.repository = repository;
            this.passwordEncoder = passwordEncoder;
            this.jwtService = jwtService;
            this.authenticationManager = authenticationManager;
        }

        public AuthenticationResponse registerAdmin(RegisterRequest request) {
            Utilisateur user = new Utilisateur();
            user.setNom(request.getNom());
            user.setPrenom(request.getPrenom());
            user.setEmail(request.getEmail());
            user.setTelephone(request.getTelephone());
            user.setMotDePasse(passwordEncoder.encode(request.getPassword()));
            user.setRole(RoleType.admin);

            repository.save(user);

            String jwtToken = jwtService.generateToken(user);
            return new AuthenticationResponse(jwtToken);
        }

        public AuthenticationResponse authenticate(AuthenticationRequest request) {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );

            Utilisateur user = repository.findByEmail(request.getEmail())
                    .orElseThrow();

            String jwtToken = jwtService.generateToken(user);
            return new AuthenticationResponse(jwtToken);
        }
    }
