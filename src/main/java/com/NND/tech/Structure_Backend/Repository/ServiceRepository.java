package com.NND.tech.Structure_Backend.Repository;

import com.NND.tech.Structure_Backend.model.entity.ServiceEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ServiceRepository extends JpaRepository<ServiceEntity, Long> {
    List<ServiceEntity> findByStructureId(Long structureId);
    List<ServiceEntity> findByStructureIdAndActiveTrue(Long structureId);
    Optional<ServiceEntity> findByIdAndActiveTrue(Long id);
    boolean existsByNameAndStructureId(String name, Long structureId);
    
    // Ajout de méthodes utiles pour la gestion des services
    List<ServiceEntity> findByStructure(com.NND.tech.Structure_Backend.model.entity.Structure structure);
    List<ServiceEntity> findByCategory(String category);
    List<ServiceEntity> findByStructureAndActiveTrue(com.NND.tech.Structure_Backend.model.entity.Structure structure);
}
