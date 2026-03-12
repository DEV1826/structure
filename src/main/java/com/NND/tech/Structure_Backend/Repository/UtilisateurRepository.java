package com.NND.tech.Structure_Backend.Repository;

import com.NND.tech.Structure_Backend.model.entity.User;
import com.NND.tech.Structure_Backend.model.entity.RoleType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UtilisateurRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    List<User> findByRole(RoleType role);
    List<User> findByStructureId(Long structureId);
    List<User> findByActiveTrue();
    Optional<User> findByIdAndActiveTrue(Long id);
    boolean existsByEmail(String email);
}
