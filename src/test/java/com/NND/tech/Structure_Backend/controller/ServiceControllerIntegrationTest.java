package com.NND.tech.Structure_Backend.controller;

import com.NND.tech.Structure_Backend.StructureBackendApplication;
import com.NND.tech.Structure_Backend.model.entity.ServiceEntity;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.Repository.ServiceRepository;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = StructureBackendApplication.class)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class ServiceControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ServiceRepository serviceRepository;

    @Autowired
    private StructureRepository structureRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private ServiceEntity testService;
    private Structure testStructure;

    @BeforeEach
    void setUp() {
        // Nettoyer la base de données avant chaque test
        serviceRepository.deleteAll();
        structureRepository.deleteAll();
        
        // Créer une structure de test
        testStructure = new Structure();
        testStructure.setName("Test Structure");
        testStructure.setAddress("123 Test St");
        testStructure = structureRepository.save(testStructure);
        
        // Créer un service de test
        testService = new ServiceEntity();
        testService.setName("Test Service");
        testService.setDescription("Test Description");
        testService.setPrice(new BigDecimal("100.00"));
        testService.setDuration(60);
        testService.setStructure(testStructure);
        testService = serviceRepository.save(testService);
    }

    @Test
    void createService_ShouldReturnCreatedService() throws Exception {
        // Arrange
        String requestBody = String.format(
            "{\"name\":\"New Service\",\"description\":\"New Description\"," +
            "\"price\":50.00,\"duration\":30,\"structureId\":%d}",
            testStructure.getId()
        );

        // Act & Assert
        mockMvc.perform(post("/api/services")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("New Service"))
                .andExpect(jsonPath("$.description").value("New Description"))
                .andExpect(jsonPath("$.price").value(50.00))
                .andExpect(jsonPath("$.duration").value(30));
    }

    @Test
    void getServiceById_ShouldReturnService_WhenFound() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/services/" + testService.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(testService.getId()))
                .andExpect(jsonPath("$.name").value("Test Service"))
                .andExpect(jsonPath("$.price").value(100.00))
                .andExpect(jsonPath("$.duration").value(60));
    }

    @Test
    void getServiceById_ShouldReturnNotFound_WhenNotExists() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/services/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void getServicesByStructure_ShouldReturnServicesForStructure() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/services/structure/" + testStructure.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].name").value("Test Service"));
    }

    @Test
    void getAllServices_ShouldReturnAllServices() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/services"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].name").value("Test Service"));
    }

    @Test
    void updateService_ShouldReturnUpdatedService() throws Exception {
        // Arrange
        String requestBody = String.format(
            "{\"name\":\"Updated Service\",\"description\":\"Updated Description\"," +
            "\"price\":150.00,\"duration\":90,\"structureId\":%d}",
            testStructure.getId()
        );

        // Act & Assert
        mockMvc.perform(put("/api/services/" + testService.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Updated Service"))
                .andExpect(jsonPath("$.description").value("Updated Description"))
                .andExpect(jsonPath("$.price").value(150.00))
                .andExpect(jsonPath("$.duration").value(90));
    }

    @Test
    void deleteService_ShouldDeleteService() throws Exception {
        // Act & Assert
        mockMvc.perform(delete("/api/services/" + testService.getId()))
                .andExpect(status().isNoContent());

        // Vérifier que le service a bien été supprimé
        assertFalse(serviceRepository.existsById(testService.getId()));
    }

    @Test
    void deleteService_ShouldReturnNotFound_WhenServiceNotExists() throws Exception {
        // Act & Assert
        mockMvc.perform(delete("/api/services/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void searchServices_ShouldReturnMatchingServices() throws Exception {
        // Ajouter un autre service pour le test de recherche
        ServiceEntity anotherService = new ServiceEntity();
        anotherService.setName("Another Service");
        anotherService.setDescription("Another Description");
        anotherService.setPrice(new BigDecimal("75.00"));
        anotherService.setDuration(45);
        anotherService.setStructure(testStructure);
        serviceRepository.save(anotherService);

        // Act & Assert - Recherche par nom
        mockMvc.perform(get("/api/services/search")
                .param("query", "Test"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].name").value("Test Service"));

        // Act & Assert - Recherche par description
        mockMvc.perform(get("/api/services/search")
                .param("query", "Another"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].name").value("Another Service"));
    }
}
