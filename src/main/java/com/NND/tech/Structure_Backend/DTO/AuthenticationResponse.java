package com.NND.tech.Structure_Backend.DTO;

import com.NND.tech.Structure_Backend.model.entity.RoleType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class AuthenticationResponse {
    private String token; // Si tu utilises JWT plus tard
    private String username;
    private String email;
    private RoleType role;
    private boolean firstLogin;
    private long expiresIn;
}