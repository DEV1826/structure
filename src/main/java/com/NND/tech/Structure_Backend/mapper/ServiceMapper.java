package com.NND.tech.Structure_Backend.mapper;

import com.NND.tech.Structure_Backend.DTO.ServiceDto;
import com.NND.tech.Structure_Backend.model.entity.ServiceEntity;
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
public interface ServiceMapper {
    
    @Mapping(target = "structure", ignore = true)
    ServiceEntity toEntity(ServiceDto dto);
    
    @Mapping(target = "structureId", source = "structure.id")
    ServiceDto toDto(ServiceEntity entity);
    
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "structure", ignore = true)
    void updateFromDto(ServiceDto dto, @MappingTarget ServiceEntity entity);
}
