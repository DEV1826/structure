package com.NND.tech.Structure_Backend.model.entity;


import com.fasterxml.jackson.annotation.JsonBackReference;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.util.Collection;
import java.util.List;
import jakarta.persistence.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "users", uniqueConstraints = {
    @UniqueConstraint(columnNames = "email")
})
public class User implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false)
    private String username; // Le nom d'utilisateur modifiable

    @Column(nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(name = "first_name")
    private String firstName;

    @Column(name = "last_name")
    private String lastName;

    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RoleType role;

    @Builder.Default
    @Column(nullable = false)
    private boolean active = true;
    @Column(nullable = false)
    private boolean firstLogin ;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "structure_id")
    @JsonBackReference
    private Structure structure;
    
    // Méthodes utilitaires
    public boolean isAdmin() {
        return role == RoleType.ADMIN || role == RoleType.SUPER_ADMIN;
    }

    public boolean isSuperAdmin() {
        return role == RoleType.SUPER_ADMIN;
    }
    
    // Ajout explicite du getter pour le champ role
    public RoleType getRole() {
        return this.role;
    }
    // pour gerer les acces Super admin et admin avec les implementation de securites

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(
                new SimpleGrantedAuthority(role.name()),          // "SUPER_ADMIN"
                new SimpleGrantedAuthority("ROLE_" + role.name()) // "ROLE_SUPER_ADMIN"
        );
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return true; }
}
