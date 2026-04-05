package com.NND.tech.Structure_Backend.mapper;

import com.NND.tech.Structure_Backend.DTO.UserDto;
import com.NND.tech.Structure_Backend.model.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;
import org.mapstruct.factory.Mappers;

@Mapper(
    componentModel = "spring",
    nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
    unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface UserMapper {
    
    UserMapper INSTANCE = Mappers.getMapper(UserMapper.class);
    
    @Mapping(target = "password", ignore = true) // Ne jamais exposer le mot de passe dans le DTO
    @Mapping(source = "structure.id", target = "structureId")
    UserDto toDto(User entity);
    
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "structure", ignore = true) // S'agit géré manuellement dans le service
    void toEntity(UserDto dto, @MappingTarget User entity);
    
    @Mapping(target = "password", ignore = true) // Ne jamais exposer le mot de passe dans le DTO
    @Mapping(source = "structure.id", target = "structureId")
    UserDto toDto(User entity, @MappingTarget UserDto dto);
    
    @Mapping(target = "id", ignore = true)
    User toEntity(UserDto dto);
}
