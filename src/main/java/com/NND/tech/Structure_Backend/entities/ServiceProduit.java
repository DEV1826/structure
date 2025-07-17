package com.NND.tech.Structure_Backend.entities;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.Objects;

@Entity

public class ServiceProduit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nom;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal prix;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "structure_id", nullable = false)
    private Structure structure;

    // --- Constructeurs ---
    public ServiceProduit() {
    }

    public ServiceProduit(String nom, String description, BigDecimal prix, Structure structure) {
        this.nom = nom;
        this.description = description;
        this.prix = prix;
        this.structure = structure;
    }

    // --- Getters et Setters ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public BigDecimal getPrix() { return prix; }
    public void setPrix(BigDecimal prix) { this.prix = prix; }
    public Structure getStructure() { return structure; }
    public void setStructure(Structure structure) { this.structure = structure; }

    // --- Equals, HashCode, ToString ---
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ServiceProduit that = (ServiceProduit) o;
        return Objects.equals(id, that.id);
    }
    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
    @Override
    public String toString() {
        return "ServiceProduit{" + "id=" + id + ", nom='" + nom + '\'' + ", prix=" + prix + '}';
    }
}
