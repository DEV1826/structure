package com.NND.tech.Structure_Backend.model.entity;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import org.springframework.lang.Nullable;

@Converter(autoApply = true)
public class RoleTypeConverter implements AttributeConverter<RoleType, String> {
    
    @Override
    @Nullable
    public String convertToDatabaseColumn(@Nullable RoleType attribute) {
        return attribute == null ? null : attribute.name().toLowerCase();
    }

    @Override
    @Nullable
    public RoleType convertToEntityAttribute(@Nullable String dbData) {
        if (dbData == null || dbData.trim().isEmpty()) {
            return null;
        }
        return RoleType.fromString(dbData);
    }
}
