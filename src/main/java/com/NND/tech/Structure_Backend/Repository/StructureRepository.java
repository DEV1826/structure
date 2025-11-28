package com.NND.tech.Structure_Backend.Repository;

import com.NND.tech.Structure_Backend.model.entity.Structure;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StructureRepository extends JpaRepository<Structure, Long> {
    List<Structure> findByActiveTrue();
    Optional<Structure> findByIdAndActiveTrue(Long id);
    boolean existsByName(String name);
}
