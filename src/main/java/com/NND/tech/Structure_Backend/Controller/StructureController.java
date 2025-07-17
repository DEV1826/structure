package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.NND.tech.Structure_Backend.entities.Structure;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/structures")
public class StructureController {

    private final StructureRepository structureRepository;

    // ✅ Constructeur explicite pour injection
    public StructureController(StructureRepository structureRepository) {
        this.structureRepository = structureRepository;
    }

    // 🔍 Obtenir toutes les structures
    @GetMapping
    public ResponseEntity<List<Structure>> getAllStructures() {
        List<Structure> structures = structureRepository.findAll();
        return ResponseEntity.ok(structures);
    }

    // 🔍 Obtenir une structure par ID
    @GetMapping("/{id}")
    public ResponseEntity<Object> getStructureById(@PathVariable Long id) {
        return structureRepository.findById(id)
                .<ResponseEntity<Object>>map(ResponseEntity::ok)
                .orElse(ResponseEntity.status(404).body("Structure non trouvée avec l'ID : " + id));
    }
}
