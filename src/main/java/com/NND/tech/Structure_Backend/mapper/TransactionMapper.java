package com.NND.tech.Structure_Backend.mapper;

import com.NND.tech.Structure_Backend.DTO.TransactionDto;
import com.NND.tech.Structure_Backend.model.entity.Transaction;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

@Mapper(
    componentModel = "spring",
    nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
    unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface TransactionMapper {
    
    @Mapping(target = "structureId", source = "structure.id")
    TransactionDto toDto(Transaction entity);
    
    @Mapping(target = "structure", ignore = true)
    Transaction toEntity(TransactionDto dto);
    
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "structure", ignore = true)
    void updateFromDto(TransactionDto dto, @MappingTarget Transaction entity);
}
