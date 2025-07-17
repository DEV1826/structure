package com.NND.tech.Structure_Backend.DTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
public class StructureRequest {
    private String nom;
    private String description;
    private String adresse;
    private String logoUrl;

    public StructureRequest() {
    }

    public StructureRequest(String nom, String description, String adresse, String logoUrl) {
        this.nom = nom;
        this.description = description;
        this.adresse = adresse;
        this.logoUrl = logoUrl;
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
}
