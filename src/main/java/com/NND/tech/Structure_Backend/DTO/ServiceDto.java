package com.NND.tech.Structure_Backend.DTO;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ServiceDto {
    private Long id;
    private String name;
    private String category;
    private String description;
    private BigDecimal price;
    private int duration;
    private boolean active;
    private Long structureId;
}
