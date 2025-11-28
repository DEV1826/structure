package com.NND.tech.Structure_Backend.controller;

import com.NND.tech.Structure_Backend.StructureBackendApplication;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.model.entity.Transaction;
import com.NND.tech.Structure_Backend.model.entity.User;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.NND.tech.Structure_Backend.Repository.TransactionRepository;
import com.NND.tech.Structure_Backend.Repository.UserRepository;
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
import java.time.LocalDate;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = StructureBackendApplication.class)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class TransactionControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StructureRepository structureRepository;

    private Transaction testTransaction;
    private User testUser;
    private Structure testStructure;

    @BeforeEach
    void setUp() {
        // Nettoyer la base de données avant chaque test
        transactionRepository.deleteAll();
        userRepository.deleteAll();
        structureRepository.deleteAll();
        
        // Créer une structure de test
        testStructure = new Structure();
        testStructure.setName("Test Structure");
        testStructure.setAddress("123 Test St");
        testStructure = structureRepository.save(testStructure);
        
        // Créer un utilisateur de test
        testUser = new User();
        testUser.setFirstName("John");
        testUser.setLastName("Doe");
        testUser.setEmail("john.doe@example.com");
        testUser.setStructure(testStructure);
        testUser = userRepository.save(testUser);
        
        // Créer une transaction de test
        testTransaction = new Transaction();
        testTransaction.setAmount(new BigDecimal("100.00"));
        testTransaction.setTransactionDate(LocalDate.now());
        testTransaction.setStructure(testStructure);
        testTransaction = transactionRepository.save(testTransaction);
    }

    @Test
    void createTransaction_ShouldReturnCreatedTransaction() throws Exception {
        // Arrange
        String requestBody = String.format(
            "{\"amount\":50.00,\"status\":\"PENDING\",\"userId\":%d,\"structureId\":%d}",
            testUser.getId(),
            testStructure.getId()
        );

        // Act & Assert
        mockMvc.perform(post("/api/transactions")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.amount").value(50.00))
                .andExpect(jsonPath("$.status").value("PENDING"));
    }

    @Test
    void getTransactionById_ShouldReturnTransaction_WhenFound() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/transactions/" + testTransaction.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(testTransaction.getId()))
                .andExpect(jsonPath("$.amount").value(100.00))
                .andExpect(jsonPath("$.status").value("PENDING"));
    }

    @Test
    void getTransactionById_ShouldReturnNotFound_WhenNotExists() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/transactions/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void getTransactionsByUserId_ShouldReturnUserTransactions() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/transactions/user/" + testUser.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].id").value(testTransaction.getId()));
    }

    @Test
    void getTransactionsByStructureId_ShouldReturnStructureTransactions() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/transactions/structure/" + testStructure.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].id").value(testTransaction.getId()));
    }

    @Test
    void updateTransactionStatus_ShouldUpdateStatus() throws Exception {
        // Act & Assert
        mockMvc.perform(put("/api/transactions/" + testTransaction.getId() + "/status")
                .contentType(MediaType.APPLICATION_JSON)
                .content("\"COMPLETED\""))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("COMPLETED"));
    }

    @Test
    void getTotalRevenue_ShouldReturnCorrectSum() throws Exception {
        // Ajouter une autre transaction pour le même utilisateur et structure
        Transaction anotherTransaction = new Transaction();
        anotherTransaction.setAmount(new BigDecimal("50.00"));
        anotherTransaction.setTransactionDate(LocalDate.now());
        anotherTransaction.setStructure(testStructure);
        transactionRepository.save(anotherTransaction);

        // Act & Assert
        mockMvc.perform(get("/api/transactions/revenue?structureId=" + testStructure.getId()))
                .andExpect(status().isOk())
                .andExpect(content().string("150.00"));
    }

    @Test
    void getTransactionCount_ShouldReturnCorrectCount() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/transactions/count?structureId=" + testStructure.getId()))
                .andExpect(status().isOk())
                .andExpect(content().string("1"));
    }

    @Test
    void getTransactionsByDateRange_ShouldReturnFilteredTransactions() throws Exception {
        // Arrange
        LocalDate now = LocalDate.now();
        String startDate = now.minusDays(1).toString();
        String endDate = now.plusDays(1).toString();

        // Act & Assert
        mockMvc.perform(get("/api/transactions/date-range")
                .param("structureId", testStructure.getId().toString())
                .param("startDate", startDate)
                .param("endDate", endDate))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].id").value(testTransaction.getId()));
    }
}
