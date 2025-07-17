package com.NND.tech.Structure_Backend.DTO;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
public class ServiceProduitRequest {
    @NotBlank(message = "Le nom ne peut pas être vide")
    private String nom;
    private String description;
    @NotNull(message = "Le prix ne peut pas être nul")
    @DecimalMin(value = "0.0", inclusive = false, message = "Le prix doit être positif")
    private BigDecimal prix;

    public ServiceProduitRequest() {
    }

    public ServiceProduitRequest(String nom, String description, BigDecimal prix) {
        this.nom = nom;
        this.description = description;
        this.prix = prix;
    }

    public @NotBlank(message = "Le nom ne peut pas être vide") String getNom() {
        return nom;
    }

    public void setNom(@NotBlank(message = "Le nom ne peut pas être vide") String nom) {
        this.nom = nom;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public @NotNull(message = "Le prix ne peut pas être nul") @DecimalMin(value = "0.0", inclusive = false, message = "Le prix doit être positif") BigDecimal getPrix() {
        return prix;
    }

    public void setPrix(@NotNull(message = "Le prix ne peut pas être nul") @DecimalMin(value = "0.0", inclusive = false, message = "Le prix doit être positif") BigDecimal prix) {
        this.prix = prix;
    }
}
