package com.NND.tech.Structure_Backend.entities;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "structures")
public class Structure {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    public Structure() {
    }

    public Structure(Long id, String nom, String description, String adresse, String logoUrl, Utilisateur admin, List<ServiceProduit> servicesProduits) {
        this.id = id;
        this.nom = nom;
        this.description = description;
        this.adresse = adresse;
        this.logoUrl = logoUrl;
        this.admin = admin;
        this.servicesProduits = servicesProduits;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getAdresse() {
        return adresse;
    }

    public void setAdresse(String adresse) {
        this.adresse = adresse;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public Utilisateur getAdmin() {
        return admin;
    }

    public void setAdmin(Utilisateur admin) {
        this.admin = admin;
    }

    public List<ServiceProduit> getServicesProduits() {
        return servicesProduits;
    }

    public void setServicesProduits(List<ServiceProduit> servicesProduits) {
        this.servicesProduits = servicesProduits;
    }

    @Column(nullable = false, unique = true)
    private String nom;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String adresse;

    private String logoUrl;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "admin_id", referencedColumnName = "id")
    @ToString.Exclude // Évite la récursion dans le toString()
    private Utilisateur admin;

    @OneToMany(mappedBy = "structure", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @ToString.Exclude
    private List<ServiceProduit> servicesProduits;


}
