package com.NND.tech.Structure_Backend.DTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ProfileUpdateRequest {

    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String phone;

    // Pour le changement de mot de passe sécurisé
    private String oldPassword;
    private String newPassword;
}