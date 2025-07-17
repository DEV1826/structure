package com.NND.tech.Structure_Backend.Service;

import com.NND.tech.Structure_Backend.DTO.RegisterAdminRequest;
import com.NND.tech.Structure_Backend.DTO.StructureRequest;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.NND.tech.Structure_Backend.Repository.UtilisateurRepository;
import com.NND.tech.Structure_Backend.entities.Structure;
import com.NND.tech.Structure_Backend.entities.Utilisateur;
import com.NND.tech.Structure_Backend.entities.RoleType;
import jakarta.transaction.Transactional;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class StructureService {

    private final StructureRepository structureRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;

    public StructureService(StructureRepository structureRepository, UtilisateurRepository utilisateurRepository, PasswordEncoder passwordEncoder) {
        this.structureRepository = structureRepository;
        this.utilisateurRepository = utilisateurRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public Structure createStructure(StructureRequest request) {
        Structure structure = new Structure();
        structure.setNom(request.getNom());
        structure.setDescription(request.getDescription());
        structure.setAdresse(request.getAdresse());
        structure.setLogoUrl(request.getLogoUrl());

        return structure;
    }

    @Transactional
    public Utilisateur createAdminForStructure(Long structureId, RegisterAdminRequest request) {
        Structure structure = structureRepository.findById(structureId)
                .orElseThrow(() -> new RuntimeException("Structure non trouvée"));

        if (structure.getAdmin() != null) {
            throw new IllegalStateException("Cette structure a déjà un administrateur.");
        }

        Utilisateur admin = new Utilisateur();
        admin.setNom(request.getNom());
        admin.setPrenom(request.getPrenom());
        admin.setEmail(request.getEmail());
        admin.setTelephone(request.getTelephone());
        admin.setMotDePasse(passwordEncoder.encode(request.getPassword()));
        admin.setRole(RoleType.ADMIN);

        Utilisateur savedAdmin = utilisateurRepository.save(admin);


        structure.setAdmin(savedAdmin);
        structureRepository.save(structure);

        return savedAdmin;
    }
}