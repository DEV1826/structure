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

import java.util.ArrayList;
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
        if (structureRepository.existsByName(request.getNom())) {
            throw new IllegalArgumentException("Une structure avec ce nom existe déjà");
        }
        
        Structure structure = new Structure();
        structure.setName(request.getNom());
        structure.setDescription(request.getDescription());
        structure.setAddress(request.getAdresse());
        structure.setImageUrl(request.getLogoUrl());
        structure.setPhone(request.getTelephone());
        structure.setEmail(request.getEmail());
        structure.setActive(true);

        Structure savedStructure = structureRepository.save(structure);
        return structureMapper.toDto(savedStructure);
    }

    @Transactional
    public StructureDto update(Long id, StructureDto structureDto) {
        Structure existingStructure = structureRepository.findByIdAndActiveTrue(id)
                .orElseThrow(() -> new ResourceNotFoundException("Structure non trouvée avec l'id : " + id));
        
        // Vérification du nom unique si modifié
        if (!existingStructure.getName().equals(structureDto.getName()) && 
            structureRepository.existsByName(structureDto.getName())) {
            throw new IllegalArgumentException("Une autre structure avec ce nom existe déjà");
        }
        
        // Update only non-null fields from the DTO
        if (structureDto.getName() != null) {
            existingStructure.setName(structureDto.getName());
        }
        if (structureDto.getDescription() != null) {
            existingStructure.setDescription(structureDto.getDescription());
        }
        if (structureDto.getAddress() != null) {
            existingStructure.setAddress(structureDto.getAddress());
        }
        if (structureDto.getImageUrl() != null) {
            existingStructure.setImageUrl(structureDto.getImageUrl());
        }
        if (structureDto.getPhone() != null) {
            existingStructure.setPhone(structureDto.getPhone());
        }
        if (structureDto.getEmail() != null) {
            existingStructure.setEmail(structureDto.getEmail());
        }
        
        Structure updatedStructure = structureRepository.save(existingStructure);
        return structureMapper.toDto(updatedStructure);
    }

    @Transactional
    public void delete(Long id) {
        Structure structure = structureRepository.findByIdAndActiveTrue(id)
                .orElseThrow(() -> new ResourceNotFoundException("Structure non trouvée avec l'id : " + id));
        
        // Soft delete
        structure.setActive(false);
        structureRepository.save(structure);
    }

    @Transactional
    public User createAdminForStructure(Long structureId, RegisterAdminRequest request) {
        Structure structure = structureRepository.findByIdAndActiveTrue(structureId)
                .orElseThrow(() -> new ResourceNotFoundException("Structure non trouvée avec l'id : " + structureId));

        User admin = new User();
        admin.setFirstName(request.getPrenom());
        admin.setLastName(request.getNom());
        admin.setEmail(request.getEmail());
        admin.setPhone(request.getTelephone());
        admin.setPassword(passwordEncoder.encode(request.getPassword()));
        admin.setRole(RoleType.ADMIN);
        admin.setStructure(structure);

        User savedAdmin = userRepository.save(admin);
        return savedAdmin;
    }
}