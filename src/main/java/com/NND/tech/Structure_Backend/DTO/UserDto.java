package com.NND.tech.Structure_Backend.DTO;

import com.NND.tech.Structure_Backend.model.entity.RoleType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    private Long id;
    private String email;
    private String password; // À utiliser avec précaution, généralement ignoré dans les réponses
    private String firstName;
    private String lastName;
    private String phone;
    private RoleType role;
    private boolean active;
    private Long structureId; // Pour lier l'utilisateur à une structure
}
