package com.NND.tech.Structure_Backend.mapper;

import com.NND.tech.Structure_Backend.DTO.StructureDto;
import com.NND.tech.Structure_Backend.model.entity.Structure;
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
public interface StructureMapper {
    
    @Mapping(target = "services", ignore = true)
    Structure toEntity(StructureDto dto);
    
    @Mapping(target = "services", ignore = true)
    StructureDto toDto(Structure entity);
    
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "services", ignore = true)
    void updateFromDto(StructureDto dto, @MappingTarget Structure entity);
}
