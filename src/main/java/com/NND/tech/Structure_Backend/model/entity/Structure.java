package com.NND.tech.Structure_Backend.model.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "structures")
@ToString(exclude = {"services", "users"})
@EqualsAndHashCode(exclude = {"services", "users"})
public class Structure {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String description;
    private String address;
    private String phone;
    private String email;
    private String imageUrl;
    private boolean active = true;

    @OneToMany(mappedBy = "structure", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<ServiceEntity> services = new ArrayList<>();
    
    @OneToMany(mappedBy = "structure", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @JsonManagedReference
    @JsonIgnoreProperties("services")

    private List<User> users = new ArrayList<>();

    public void addService(ServiceEntity service) {
        services.add(service);
        service.setStructure(this);
    }

    public void removeService(ServiceEntity service) {
        services.remove(service);
        service.setStructure(null);
    }
    
    public void setActive(boolean active) {
        this.active = active;
    }
    
    public void setServicesProduits(List<ServiceEntity> services) {
        this.services.clear();
        if (services != null) {
            this.services.addAll(services);
        }
    }
}
