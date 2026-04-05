package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.DTO.RegisterAdminRequest;
import com.NND.tech.Structure_Backend.DTO.StructureDto;
import com.NND.tech.Structure_Backend.DTO.StructureRequest;
import com.NND.tech.Structure_Backend.DTO.UserDto;
import com.NND.tech.Structure_Backend.Service.StructureService;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.model.entity.User;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.web.bind.annotation.*;

@RestController
@EnableMethodSecurity
@RequestMapping("/api/superadmin")
@PreAuthorize("hasAnyAuthority('SUPER_ADMIN', 'ROLE_SUPER_ADMIN')")

public class SuperAdminController {

    private final StructureService structureService;

    public SuperAdminController(StructureService structureService) {
        this.structureService = structureService;
    }

    @PostMapping("/structures")
    public ResponseEntity<StructureDto> createStructure(@Valid @RequestBody StructureRequest request) {
        return ResponseEntity.ok(structureService.create(request));
    }

    @PostMapping("/structures/{id}/admin")
    public ResponseEntity<UserDto> createAdminForStructure(
            @PathVariable("id") Long structureId,
            @Valid @RequestBody RegisterAdminRequest request) {
        User createdUser = structureService.createAdminForStructure(structureId, request);
        return ResponseEntity.ok(com.NND.tech.Structure_Backend.mapper.UserMapper.INSTANCE.toDto(createdUser));
    }
}