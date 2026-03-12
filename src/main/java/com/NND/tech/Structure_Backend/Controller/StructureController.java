package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.DTO.StructureRequest;
import com.NND.tech.Structure_Backend.DTO.StructureDto;
import com.NND.tech.Structure_Backend.Service.StructureService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/structures")
@RequiredArgsConstructor
public class StructureController {

    private final StructureService structureService;

    @GetMapping
    public ResponseEntity<List<StructureDto>> getAllStructures() {
        return ResponseEntity.ok(structureService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<StructureDto> getStructureById(@PathVariable Long id) {
        return ResponseEntity.ok(structureService.findById(id));
    }

    @PostMapping
    public ResponseEntity<StructureDto> createStructure(@Valid @RequestBody StructureRequest request) {
        StructureDto created = structureService.create(request);
        return ResponseEntity
                .created(URI.create("/api/structures/" + created.getId()))
                .body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<StructureDto> updateStructure(
            @PathVariable Long id,
            @Valid @RequestBody StructureDto structureDto) {
        return ResponseEntity.ok(structureService.update(id, structureDto));
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteStructure(@PathVariable Long id) {
        structureService.delete(id);
    }

    @GetMapping("/active")
    public ResponseEntity<List<StructureDto>> getActiveStructures() {
        return ResponseEntity.ok(structureService.findAll());
    }
}
