package com.NND.tech.Structure_Backend.DTO;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionDto {
    private Long id;
    private Long structureId;
    private Long serviceId;
    private Long userId;
    private BigDecimal amount;
    private String paymentMethod;
    private String status;
    private String reference;
    
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime transactionDate;
    
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String description;
    private String metadata;
    private boolean active = true;
}
