package com.NND.tech.Structure_Backend.Service;

import com.NND.tech.Structure_Backend.DTO.TransactionDto;
import com.NND.tech.Structure_Backend.Exception.ResourceNotFoundException;
import com.NND.tech.Structure_Backend.mapper.TransactionMapper;
import com.NND.tech.Structure_Backend.model.entity.Transaction;
import com.NND.tech.Structure_Backend.Repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface TransactionService {
    List<TransactionDto> findAll();
    TransactionDto findById(Long id);
    List<TransactionDto> findByStructureId(Long structureId);
    TransactionDto create(TransactionDto transactionDto);
    TransactionDto update(Long id, TransactionDto transactionDto);
    void delete(Long id);
}

@Service
@RequiredArgsConstructor
class TransactionServiceImpl implements TransactionService {

    private final TransactionRepository transactionRepository;
    private final TransactionMapper transactionMapper;

    @Override
    @Transactional(readOnly = true)
    public List<TransactionDto> findAll() {
        return transactionRepository.findAll().stream()
                .map(transactionMapper::toDto)
                .collect(java.util.stream.Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public TransactionDto findById(Long id) {
        return transactionRepository.findById(id)
                .map(transactionMapper::toDto)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction non trouvée avec l'ID : " + id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<TransactionDto> findByStructureId(Long structureId) {
        return transactionRepository.findByStructureId(structureId).stream()
                .map(transactionMapper::toDto)
                .collect(java.util.stream.Collectors.toList());
    }

    @Override
    @Transactional
    public TransactionDto create(TransactionDto transactionDto) {
        Transaction transaction = transactionMapper.toEntity(transactionDto);
        Transaction savedTransaction = transactionRepository.save(transaction);
        return transactionMapper.toDto(savedTransaction);
    }

    @Override
    @Transactional
    public TransactionDto update(Long id, TransactionDto transactionDto) {
        Transaction existingTransaction = transactionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction non trouvée avec l'ID : " + id));
        
        transactionMapper.updateFromDto(transactionDto, existingTransaction);
        Transaction updatedTransaction = transactionRepository.save(existingTransaction);
        return transactionMapper.toDto(updatedTransaction);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!transactionRepository.existsById(id)) {
            throw new ResourceNotFoundException("Transaction non trouvée avec l'ID : " + id);
        }
        transactionRepository.deleteById(id);
    }
}
