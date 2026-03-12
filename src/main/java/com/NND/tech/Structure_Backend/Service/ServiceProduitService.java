package com.NND.tech.Structure_Backend.Service;

import com.NND.tech.Structure_Backend.DTO.ServiceProduitRequest;
import com.NND.tech.Structure_Backend.Repository.ServiceRepository;
import com.NND.tech.Structure_Backend.Repository.UserRepository;
import com.NND.tech.Structure_Backend.model.entity.ServiceEntity;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.model.entity.User;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;


@Service
public class ServiceProduitService {

    private final ServiceRepository serviceRepository;
    private final UserRepository userRepository;

    public ServiceProduitService(ServiceRepository serviceRepository, UserRepository userRepository) {
        this.serviceRepository = serviceRepository;
        this.userRepository = userRepository;
    }

    public ServiceEntity createServiceProduit(ServiceProduitRequest request, String adminEmail) {
        User admin = userRepository.findByEmail(adminEmail)
                .orElseThrow(() -> new UsernameNotFoundException("Admin non trouvé: " + adminEmail));

        Structure structure = admin.getStructure();
        if (structure == null) {
            throw new IllegalStateException("Cet admin n'est associé à aucune structure.");
        }

        ServiceEntity service = new ServiceEntity();
        service.setName(request.getNom());
        service.setDescription(request.getDescription());
        service.setPrice(request.getPrix());
        service.setStructure(structure);
        service.setCategory("default"); // Valeur par défaut, à mettre à jour selon la logique métier
        service.setDuration(0); // Valeur par défaut, à mettre à jour selon la logique métier
        service.setActive(true);

        return serviceRepository.save(service);
    }

    public ServiceEntity updateServiceProduit(Long serviceId, ServiceProduitRequest request, String adminEmail) {
        ServiceEntity service = serviceRepository.findById(serviceId)
                .orElseThrow(() -> new IllegalArgumentException("Service/Produit non trouvé avec l'id: " + serviceId));

        checkOwnership(service, adminEmail);

        service.setName(request.getNom());
        service.setDescription(request.getDescription());
        service.setPrice(request.getPrix());
        // Mettre à jour d'autres champs si nécessaire

        return serviceRepository.save(service);
    }

    public void deleteServiceProduit(Long serviceId, String adminEmail) {
        ServiceEntity service = serviceRepository.findById(serviceId)
                .orElseThrow(() -> new IllegalArgumentException("Service/Produit non trouvé avec l'id: " + serviceId));

        checkOwnership(service, adminEmail);

        serviceRepository.delete(service);
    }

    private void checkOwnership(ServiceEntity service, String adminEmail) {
        User admin = userRepository.findByEmail(adminEmail)
                .orElseThrow(() -> new UsernameNotFoundException("Admin non trouvé: " + adminEmail));

        Structure structure = admin.getStructure();
        if (structure == null || !service.getStructure().getId().equals(structure.getId())) {
            throw new IllegalArgumentException("L'utilisateur n'est pas autorisé à modifier ce service/produit.");
        }
    }
}