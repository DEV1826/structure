package com.NND.tech.Structure_Backend.controller;

import com.NND.tech.Structure_Backend.StructureBackendApplication;
import com.NND.tech.Structure_Backend.DTO.StructureDto;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Timeout;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = StructureBackendApplication.class)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class StructureControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private StructureRepository structureRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private Structure testStructure;

    @BeforeEach
    void setUp() {
        // Nettoyer la base de données avant chaque test
        structureRepository.deleteAll();
        
        // Créer une structure de test
        testStructure = new Structure();
        testStructure.setName("Test Structure");
        testStructure.setAddress("123 Test St");
        testStructure.setActive(true);
        testStructure = structureRepository.save(testStructure);
    }

    @Test
    void createStructure_ShouldReturnCreatedStructure() throws Exception {
        // Arrange
        StructureDto newStructure = new StructureDto();
        newStructure.setName("New Structure");
        newStructure.setAddress("456 New St");
        newStructure.setActive(true);

        // Act & Assert
        mockMvc.perform(post("/api/structures")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(newStructure)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("New Structure"))
                .andExpect(jsonPath("$.address").value("456 New St"))
                .andExpect(jsonPath("$.active").value(true));
    }

    @Test
    void getStructureById_ShouldReturnStructure_WhenFound() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/structures/" + testStructure.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(testStructure.getId()))
                .andExpect(jsonPath("$.name").value("Test Structure"))
                .andExpect(jsonPath("$.address").value("123 Test St"));
    }

    @Test
    void getStructureById_ShouldReturnNotFound_WhenNotExists() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/structures/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void getAllStructures_ShouldReturnAllStructures() throws Exception {
        // Arrange
        Structure anotherStructure = new Structure();
        anotherStructure.setName("Another Structure");
        anotherStructure.setAddress("789 Another St");
        structureRepository.save(anotherStructure);

        // Act & Assert
        mockMvc.perform(get("/api/structures"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].name").value("Test Structure"))
                .andExpect(jsonPath("$[1].name").value("Another Structure"));
    }

    @Test
    void updateStructure_ShouldReturnUpdatedStructure() throws Exception {
        // Arrange
        StructureDto updatedStructure = new StructureDto();
        updatedStructure.setName("Updated Structure");
        updatedStructure.setAddress("Updated Address");
        updatedStructure.setActive(false);

        // Act & Assert
        mockMvc.perform(put("/api/structures/" + testStructure.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedStructure)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Updated Structure"))
                .andExpect(jsonPath("$.address").value("Updated Address"))
                .andExpect(jsonPath("$.active").value(false));
    }

    @Test
    void deleteStructure_ShouldDeleteStructure() throws Exception {
        // Act & Assert
        mockMvc.perform(delete("/api/structures/" + testStructure.getId()))
                .andExpect(status().isNoContent());

        // Vérifier que la structure a bien été supprimée
        assertFalse(structureRepository.findById(testStructure.getId()).isPresent());
    }

    @Test
    void deleteStructure_ShouldReturnNotFound_WhenNotExists() throws Exception {
        // Act & Assert
        mockMvc.perform(delete("/api/structures/999"))
                .andExpect(status().isNotFound());
    }
    
    // Tests de validation
    @Test
    void createStructure_ShouldReturnBadRequest_WhenNameIsEmpty() throws Exception {
        StructureDto invalidStructure = new StructureDto();
        invalidStructure.setName(""); // Nom vide
        invalidStructure.setAddress("123 Test St");
        
        mockMvc.perform(post("/api/structures")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidStructure)))
                .andExpect(status().isBadRequest());
    }
    
    @Test
    void createStructure_ShouldReturnBadRequest_WhenAddressIsNull() throws Exception {
        StructureDto invalidStructure = new StructureDto();
        invalidStructure.setName("Test Structure");
        // address est null
        
        mockMvc.perform(post("/api/structures")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidStructure)))
                .andExpect(status().isBadRequest());
    }
    
    // Tests de performance
    @Test
    @DisplayName("Devrait gérer efficacement un grand nombre de structures")
    @Timeout(5) // 5 secondes maximum pour ce test
    void getAllStructures_ShouldHandleLargeNumberOfStructures() throws Exception {
        // Créer un grand nombre de structures
        for (int i = 0; i < 1000; i++) {
            Structure structure = new Structure();
            structure.setName("Structure " + i);
            structure.setAddress("Address " + i);
            structure.setActive(true);
            structureRepository.save(structure);
        }
        
        // Vérifier que la requête s'exécute dans un temps raisonnable
        mockMvc.perform(get("/api/structures"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$", hasSize(greaterThan(999))));
    }
    
    // Tests de sécurité
    @Test
    @WithMockUser(roles = "USER")
    void updateStructure_ShouldReturnForbidden_WhenNotAdmin() throws Exception {
        StructureDto updatedStructure = new StructureDto();
        updatedStructure.setName("Updated Structure");
        updatedStructure.setAddress("Updated Address");
        
        mockMvc.perform(put("/api/structures/" + testStructure.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedStructure)))
                .andExpect(status().isForbidden());
    }
    
    @Test
    @WithMockUser(roles = "ADMIN")
    void updateStructure_ShouldSucceed_WhenAdmin() throws Exception {
        StructureDto updatedStructure = new StructureDto();
        updatedStructure.setName("Updated Structure");
        updatedStructure.setAddress("Updated Address");
        
        mockMvc.perform(put("/api/structures/" + testStructure.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedStructure)))
                .andExpect(status().isOk());
    }
    
    // Tests de cas limites
    @Test
    void createStructure_ShouldHandleLongNames() throws Exception {
        String longName = "A".repeat(500); // Nom très long
        StructureDto structure = new StructureDto();
        structure.setName(longName);
        structure.setAddress("123 Test St");
        
        mockMvc.perform(post("/api/structures")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(structure)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value(longName));
    }
    
    @Test
    void createStructure_ShouldHandleSpecialCharacters() throws Exception {
        String nameWithSpecialChars = "Structure avec caractères spéciaux: éàçù@#{}[]|\\/!?%*$";
        StructureDto structure = new StructureDto();
        structure.setName(nameWithSpecialChars);
        structure.setAddress("123 Test St");
        
        mockMvc.perform(post("/api/structures")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(structure)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value(nameWithSpecialChars));
    }
}
