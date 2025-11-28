package com.NND.tech.Structure_Backend.service;

import com.NND.tech.Structure_Backend.DTO.TransactionDto;
import com.NND.tech.Structure_Backend.Exception.ResourceNotFoundException;
import com.NND.tech.Structure_Backend.mapper.TransactionMapper;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.model.entity.Transaction;
import com.NND.tech.Structure_Backend.model.entity.User;
import com.NND.tech.Structure_Backend.Repository.TransactionRepository;
import org.junit.jupiter.api.BeforeEach; 
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TransactionServiceTest {

    @Mock
    private TransactionRepository transactionRepository;

    // @Mock
    // private UserRepository userRepository;

    @Mock
    private TransactionMapper transactionMapper;

    @InjectMocks
    private TransactionServiceImpl transactionService;

    private Transaction testTransaction;
    private TransactionDto testTransactionDto;
    private final Long transactionId = 1L;
    private final Long userId = 1L;

    @BeforeEach
    void setUp() {
        // Create test structure
        Structure structure = new Structure();
        structure.setId(1L);
        structure.setName("Test Structure");

        // Create test transaction
        testTransaction = new Transaction();
        testTransaction.setId(transactionId);
        testTransaction.setAmount(new BigDecimal("100.00"));
        testTransaction.setTransactionDate(LocalDate.now());
        testTransaction.setStructure(structure);

        // Create test DTO
        testTransactionDto = new TransactionDto();
        testTransactionDto.setId(transactionId);
        testTransactionDto.setAmount(new BigDecimal("100.00"));
        testTransactionDto.setStatus("COMPLETED");
        testTransactionDto.setTransactionDate(LocalDate.now().atStartOfDay());
        testTransactionDto.setUserId(userId);
        testTransactionDto.setStructureId(1L);
    }

    @Test
    void createTransaction_ShouldReturnCreatedTransaction() {
        // Arrange
        when(transactionMapper.toEntity(any(TransactionDto.class))).thenReturn(testTransaction);
        when(transactionRepository.save(any(Transaction.class))).thenReturn(testTransaction);
        when(transactionMapper.toDto(any(Transaction.class))).thenReturn(testTransactionDto);

        // Act
        TransactionDto result = transactionService.create(testTransactionDto);

        // Assert
        assertNotNull(result);
        assertEquals(testTransactionDto.getAmount(), result.getAmount());
        assertEquals(testTransactionDto.getStatus(), result.getStatus());
        verify(transactionRepository, times(1)).save(any(Transaction.class));
    }

    @Test
    void getTransactionById_ShouldReturnTransaction_WhenFound() {
        // Arrange
        when(transactionRepository.findById(transactionId)).thenReturn(Optional.of(testTransaction));
        when(transactionMapper.toDto(any(Transaction.class))).thenReturn(testTransactionDto);

        // Act
        TransactionDto result = transactionService.findById(transactionId);

        // Assert
        assertNotNull(result);
        assertEquals(transactionId, result.getId());
        verify(transactionRepository, times(1)).findById(transactionId);
    }

    @Test
    void getTransactionById_ShouldThrowException_WhenNotFound() {
        // Arrange
        when(transactionRepository.findById(transactionId)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            transactionService.findById(transactionId);
        });
        verify(transactionRepository, times(1)).findById(transactionId);
    }

    // Test getTransactionsByUserId supprimé: méthode non exposée dans le service actuel

    @Test
    void getTransactionsByStructureId_ShouldReturnStructureTransactions() {
        // Arrange
        Long structureId = 1L;
        List<Transaction> transactions = Arrays.asList(testTransaction);
        when(transactionRepository.findByStructureId(structureId)).thenReturn(transactions);
        when(transactionMapper.toDto(any(Transaction.class))).thenReturn(testTransactionDto);

        // Act
        List<TransactionDto> result = transactionService.findByStructureId(structureId);

        // Assert
        assertEquals(1, result.size());
        verify(transactionRepository, times(1)).findByStructureId(structureId);
    }

    // Test updateTransactionStatus supprimé: API actuelle n'expose pas cette méthode

    // Test calculateTotalRevenue supprimé: méthode non exposée dans le service actuel

    // Test getTransactionCount supprimé: méthode non exposée dans le service actuel

    // Test getTransactionsByDateRange supprimé: méthode non exposée dans le service actuel
}
