package com.NND.tech.Structure_Backend.Service;

import com.NND.tech.Structure_Backend.DTO.StructureDto;
import com.NND.tech.Structure_Backend.DTO.RegisterAdminRequest;
import com.NND.tech.Structure_Backend.DTO.StructureRequest;
import com.NND.tech.Structure_Backend.Exception.ResourceNotFoundException;
import com.NND.tech.Structure_Backend.mapper.StructureMapper;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.model.entity.User;
import com.NND.tech.Structure_Backend.model.entity.RoleType;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.NND.tech.Structure_Backend.Repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StructureService {

    private final StructureRepository structureRepository;
    private final UserRepository userRepository;
    private final StructureMapper structureMapper;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public List<StructureDto> findAll() {
        return structureRepository.findByActiveTrue().stream()
                .map(structureMapper::toDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public StructureDto findById(Long id) {
        return structureRepository.findByIdAndActiveTrue(id)
                .map(structureMapper::toDto)
                .orElseThrow(() -> new ResourceNotFoundException("Structure non trouvée avec l'id : " + id));
    }

    @Transactional
    public StructureDto create(StructureRequest request) {
        if (structureRepository.existsByName(request.getName())) {
            throw new IllegalArgumentException("Une structure avec ce nom existe déjà");
        }

        Structure structure = new Structure();
        structure.setName(request.getName());
        structure.setDescription(request.getDescription());
        structure.setAddress(request.getAddress());
        structure.setImageUrl(request.getImageUrl());
        structure.setPhone(request.getPhone());
        structure.setEmail(request.getEmail());
        structure.setActive(true);

        // On sauvegarde d'abord la structure pour lui donner un ID
        Structure savedStructure = structureRepository.save(structure);

        // Association d'un administrateur si fourni
        if (request.getAdminId() != null) {
            User admin = userRepository.findById(request.getAdminId())
                    .orElseThrow(() -> new ResourceNotFoundException("Administrateur non trouvé avec l'id : " + request.getAdminId()));
            
            // On s'assure que cet utilisateur est bien un ADMIN
            if (admin.getRole() != RoleType.ADMIN) {
                throw new IllegalArgumentException("L'utilisateur sélectionné n'est pas un administrateur");
            }
            
            admin.setStructure(savedStructure);
            // Sécurité : s'assurer que l'admin a un username avant la sauvegarde
            if (admin.getUsername() == null || admin.getUsername().isEmpty()) {
                admin.setUsername(admin.getEmail());
            }
            userRepository.save(admin);
        }

        return structureMapper.toDto(savedStructure);
    }

    @Transactional
    public StructureDto update(Long id, StructureDto structureDto) {
        Structure existingStructure = structureRepository.findByIdAndActiveTrue(id)
                .orElseThrow(() -> new ResourceNotFoundException("Structure non trouvée avec l'id : " + id));

        if (!existingStructure.getName().equals(structureDto.getName()) &&
                structureRepository.existsByName(structureDto.getName())) {
            throw new IllegalArgumentException("Une autre structure avec ce nom existe déjà");
        }

        if (structureDto.getName() != null) existingStructure.setName(structureDto.getName());
        if (structureDto.getDescription() != null) existingStructure.setDescription(structureDto.getDescription());
        if (structureDto.getAddress() != null) existingStructure.setAddress(structureDto.getAddress());
        if (structureDto.getImageUrl() != null) existingStructure.setImageUrl(structureDto.getImageUrl());
        if (structureDto.getPhone() != null) existingStructure.setPhone(structureDto.getPhone());
        if (structureDto.getEmail() != null) existingStructure.setEmail(structureDto.getEmail());

        Structure updatedStructure = structureRepository.save(existingStructure);
        return structureMapper.toDto(updatedStructure);
    }

    @Transactional
    public void delete(Long id) {
        Structure structure = structureRepository.findByIdAndActiveTrue(id)
                .orElseThrow(() -> new ResourceNotFoundException("Structure non trouvée avec l'id : " + id));
        structure.setActive(false);
        structureRepository.save(structure);
    }

    @Transactional
    public User createAdminForStructure(Long structureId, RegisterAdminRequest request) {
        System.out.println("DEBUG: Création admin pour structure " + structureId);
        System.out.println("DEBUG: Request -> Nom: " + request.getNom() + ", Prenom: " + request.getPrenom() + ", Username: " + request.getUsername());

        // 1. On cherche la structure
        Structure structure = structureRepository.findByIdAndActiveTrue(structureId)
                .orElseThrow(() -> new ResourceNotFoundException("Structure non trouvée avec l'id : " + structureId));

        // 2. Création de l'objet User (Admin)
        User admin = new User();

        // On utilise les getters
        admin.setFirstName(request.getPrenom());
        admin.setLastName(request.getNom());
        admin.setEmail(request.getEmail());
        admin.setPhone(request.getTelephone());
        admin.setUsername(request.getUsername());

        // Encodage du mot de passe
        admin.setPassword(passwordEncoder.encode(request.getPassword()));

        // Attribution des droits et de la structure
        admin.setRole(RoleType.ADMIN);
        admin.setStructure(structure);

        // Initialisation des statuts
        admin.setActive(true);
        admin.setFirstLogin(true);

        // 3. Sauvegarde en base de données
        System.out.println("DEBUG: Tentative de sauvegarde d'un admin :");
        System.out.println(" - Nom: " + admin.getLastName());
        System.out.println(" - Prénom: " + admin.getFirstName());
        System.out.println(" - Email: " + admin.getEmail());
        System.out.println(" - Structure ID: " + (admin.getStructure() != null ? admin.getStructure().getId() : "NULL"));

        return userRepository.save(admin);
    }
}