package com.NND.tech.Structure_Backend.DTO;

import lombok.Data;

import java.util.List;

@Data
public class StructureDto {
    private Long id;
    private String name;
    private String description;
    private String address;
    private String phone;
    private String email;
    private String imageUrl;
    private boolean active;
    private List<ServiceDto> services;
}
