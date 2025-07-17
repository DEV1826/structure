package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.DTO.RegisterAdminRequest;
import com.NND.tech.Structure_Backend.DTO.StructureRequest;
import com.NND.tech.Structure_Backend.Service.StructureService;
import com.NND.tech.Structure_Backend.entities.Structure;
import com.NND.tech.Structure_Backend.entities.Utilisateur;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/superadmin")
@PreAuthorize("hasAuthority('SUPER_ADMIN')")

public class SuperAdminController {

    private final StructureService structureService;

    public SuperAdminController(StructureService structureService) {
        this.structureService = structureService;
    }

    @PostMapping("/structures")
    public ResponseEntity<Structure> createStructure(@Valid @RequestBody StructureRequest request) {
        return ResponseEntity.ok(structureService.createStructure(request));
    }

    @PostMapping("/structures/{id}/admin")
    public ResponseEntity<Utilisateur> createAdminForStructure(
            @PathVariable("id") Long structureId,
            @Valid @RequestBody RegisterAdminRequest request) {
        return ResponseEntity.ok(structureService.createAdminForStructure(structureId, request));
    }
}