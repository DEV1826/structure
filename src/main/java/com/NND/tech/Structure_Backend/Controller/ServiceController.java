package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.DTO.ServiceDto;
import com.NND.tech.Structure_Backend.Service.ServiceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/structures/{structureId}/services")
@RequiredArgsConstructor
public class ServiceController {

    private final ServiceService serviceService;

    @GetMapping
    public ResponseEntity<List<ServiceDto>> getServicesByStructure(@PathVariable Long structureId) {
        return ResponseEntity.ok(serviceService.findByStructureId(structureId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ServiceDto> getService(@PathVariable Long structureId, @PathVariable Long id) {
        return ResponseEntity.ok(serviceService.findById(id));
    }

    @PostMapping
    public ResponseEntity<ServiceDto> createService(
            @PathVariable Long structureId,
            @Valid @RequestBody ServiceDto serviceDto) {
        ServiceDto created = serviceService.create(structureId, serviceDto);
        return ResponseEntity
                .created(URI.create("/api/structures/" + structureId + "/services/" + created.getId()))
                .body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ServiceDto> updateService(
            @PathVariable Long structureId,
            @PathVariable Long id,
            @Valid @RequestBody ServiceDto serviceDto) {
        return ResponseEntity.ok(serviceService.update(id, serviceDto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteService(
            @PathVariable Long structureId,
            @PathVariable Long id) {
        serviceService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
