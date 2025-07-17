package com.NND.tech.Structure_Backend.Repository;

import com.NND.tech.Structure_Backend.entities.Structure;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StructureRepository extends JpaRepository<Structure, Long> {
}
