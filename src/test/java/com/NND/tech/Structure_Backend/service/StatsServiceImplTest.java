package com.NND.tech.Structure_Backend.service;

import com.NND.tech.Structure_Backend.DTO.StatsDto;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.NND.tech.Structure_Backend.Repository.TransactionRepository;
import com.NND.tech.Structure_Backend.Repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class StatsServiceImplTest {

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private StructureRepository structureRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private StatsServiceImpl statsService;

    private final LocalDate startDate = LocalDate.of(2023, 1, 1);
    private final LocalDate endDate = LocalDate.of(2023, 12, 31);
    private final Long structureId = 1L;
    private final String structureName = "Test Structure";

    @Test
    void getGlobalStats_ShouldReturnCorrectStats() {
        // Arrange
        when(transactionRepository.count()).thenReturn(100L);
        when(transactionRepository.getTotalRevenue()).thenReturn(5000.0);
        when(structureRepository.count()).thenReturn(5L);
        when(userRepository.count()).thenReturn(20L);

        // Act
        StatsDto result = statsService.getGlobalStats();

        // Assert
        assertNotNull(result);
        assertEquals(100L, result.getTotalTransactions());
        assertEquals(5000.0, result.getTotalRevenue());
        assertEquals(5L, result.getTotalStructures());
        assertEquals(20L, result.getTotalUsers());
    }

    @Test
    void getStatsByDateRange_ShouldReturnStatsForDateRange() {
        // Arrange
        when(transactionRepository.countByTransactionDateBetween(startDate, endDate)).thenReturn(50L);
        when(transactionRepository.getTotalRevenueByDateRange(startDate, endDate)).thenReturn(2500.0);

        // Act
        StatsDto result = statsService.getStatsByDateRange(startDate, endDate);

        // Assert
        assertNotNull(result);
        assertEquals(50L, result.getTransactionsInPeriod());
        assertEquals(2500.0, result.getRevenueInPeriod());
    }

    @Test
    void getStatsByStructure_ShouldReturnStatsForStructure() {
        // Arrange
        Structure structure = new Structure();
        structure.setId(structureId);
        structure.setName(structureName);

        when(structureRepository.findById(structureId)).thenReturn(Optional.of(structure));
        when(transactionRepository.countByStructureId(structureId)).thenReturn(30L);
        when(transactionRepository.getTotalRevenueByStructureId(structureId)).thenReturn(1500.0);

        // Act
        StatsDto result = statsService.getStatsByStructure(structureId);

        // Assert
        assertNotNull(result);
        assertEquals(30L, result.getTotalTransactions());
        assertEquals(1500.0, result.getTotalRevenue());
        assertEquals(structureId, result.getStructureId());
        assertEquals(structureName, result.getStructureName());
    }

    @Test
    void getStatsByDateRange_ShouldThrowException_WhenStartDateAfterEndDate() {
        // Arrange
        LocalDate invalidStartDate = LocalDate.of(2024, 1, 1);
        LocalDate invalidEndDate = LocalDate.of(2023, 1, 1);

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> statsService.getStatsByDateRange(invalidStartDate, invalidEndDate)
        );
        
        assertEquals("La date de début doit être antérieure à la date de fin", exception.getMessage());
    }

    @Test
    void getStatsByStructure_ShouldThrowException_WhenStructureNotFound() {
        // Arrange
        when(structureRepository.findById(structureId)).thenReturn(Optional.empty());

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> statsService.getStatsByStructure(structureId)
        );
        
        assertEquals("Structure non trouvée avec l'ID : " + structureId, exception.getMessage());
    }
}
