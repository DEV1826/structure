package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.DTO.ServiceProduitRequest;
import com.NND.tech.Structure_Backend.Service.ServiceProduitService;
import com.NND.tech.Structure_Backend.entities.ServiceProduit;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasAnyAuthority('ADMIN', 'SUPER_ADMIN')")
public class AdminController {

    private final ServiceProduitService serviceProduitService;

    public AdminController(ServiceProduitService serviceProduitService) {
        this.serviceProduitService = serviceProduitService;
    }

    @PostMapping("/services")
    public ResponseEntity<?> createServiceProduit(
            @Valid @RequestBody ServiceProduitRequest request,
            Principal principal
    ) {
        try {
            ServiceProduit produit = serviceProduitService.createServiceProduit(request, principal.getName());
            return ResponseEntity.status(HttpStatus.CREATED).body(produit);
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().body("Erreur métier : " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erreur interne : " + e.getMessage());
        }
    }

    @PutMapping("/services/{id}")
    public ResponseEntity<?> updateServiceProduit(
            @PathVariable Long id,
            @Valid @RequestBody ServiceProduitRequest request,
            Principal principal
    ) {
        try {
            ServiceProduit produit = serviceProduitService.updateServiceProduit(id, request, principal.getName());
            return ResponseEntity.ok(produit);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Erreur : " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erreur interne : " + e.getMessage());
        }
    }

    @DeleteMapping("/services/{id}")
    public ResponseEntity<?> deleteServiceProduit(
            @PathVariable Long id,
            Principal principal
    ) {
        try {
            serviceProduitService.deleteServiceProduit(id, principal.getName());
            return ResponseEntity.ok("Service/Produit supprimé avec succès.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Erreur : " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Erreur interne : " + e.getMessage());
        }
    }
}
