package com.NND.tech.Structure_Backend.Service;


import com.NND.tech.Structure_Backend.DTO.ServiceProduitRequest;
import com.NND.tech.Structure_Backend.Repository.ServiceProduitRepository;
import com.NND.tech.Structure_Backend.Repository.UtilisateurRepository;
import com.NND.tech.Structure_Backend.entities.ServiceProduit;
import com.NND.tech.Structure_Backend.entities.Structure;
import com.NND.tech.Structure_Backend.entities.Utilisateur;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service

public class ServiceProduitService {

    private final ServiceProduitRepository serviceProduitRepository;
    private final UtilisateurRepository utilisateurRepository;

    public ServiceProduitService(ServiceProduitRepository serviceProduitRepository, UtilisateurRepository utilisateurRepository) {
        this.serviceProduitRepository = serviceProduitRepository;
        this.utilisateurRepository = utilisateurRepository;
    }

    public ServiceProduit createServiceProduit(ServiceProduitRequest request, String adminEmail) {
        Utilisateur admin = utilisateurRepository.findByEmail(adminEmail)
                .orElseThrow(() -> new UsernameNotFoundException("Admin non trouvé: " + adminEmail));

        Structure structure = admin.getStructure();
        if (structure == null) {
            throw new IllegalStateException("Cet admin n'est associé à aucune structure.");
        }

        ServiceProduit serviceProduit = new ServiceProduit(
                request.getNom(),
                request.getDescription(),
                request.getPrix(),
                structure
        );

        return serviceProduitRepository.save(serviceProduit);
    }

    public ServiceProduit updateServiceProduit(Long serviceId, ServiceProduitRequest request, String adminEmail) {
        ServiceProduit serviceProduit = serviceProduitRepository.findById(serviceId)
                .orElseThrow(() -> new IllegalArgumentException("Service/Produit non trouvé avec l'id: " + serviceId));

        checkOwnership(serviceProduit, adminEmail);

        serviceProduit.setNom(request.getNom());
        serviceProduit.setDescription(request.getDescription());
        serviceProduit.setPrix(request.getPrix());

        return serviceProduitRepository.save(serviceProduit);
    }

    public void deleteServiceProduit(Long serviceId, String adminEmail) {
        ServiceProduit serviceProduit = serviceProduitRepository.findById(serviceId)
                .orElseThrow(() -> new IllegalArgumentException("Service/Produit non trouvé avec l'id: " + serviceId));

        checkOwnership(serviceProduit, adminEmail);

        serviceProduitRepository.delete(serviceProduit);
    }

    private void checkOwnership(ServiceProduit serviceProduit, String adminEmail) {
        Utilisateur admin = utilisateurRepository.findByEmail(adminEmail)
                .orElseThrow(() -> new UsernameNotFoundException("Admin non trouvé: " + adminEmail));

        Structure structure = admin.getStructure();
        if (structure == null || !serviceProduit.getStructure().getId().equals(structure.getId())) {
            throw new IllegalArgumentException("L'utilisateur n'est pas autorisé à modifier ce service/produit.");
        }
    }
}