package com.NND.tech.Structure_Backend.model.entity;

public enum RoleType {
    SUPER_ADMIN, ADMIN, USER;

    public static RoleType fromString(String value) {
        if (value == null) return null;
        try {
            return RoleType.valueOf(value.toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
