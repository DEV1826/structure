package com.NND.tech.Structure_Backend.DTO;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AuthenticationRequest {

    // Cet identifiant peut être soit l'email, soit le username
    private String identifier;
    private String password;
}