package com.NND.tech.Structure_Backend.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "transactions")
public class Transaction {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String reference;
    
    @Column(nullable = false)
    private BigDecimal amount;
    
    @Column(name = "transaction_date", nullable = false)
    private LocalDate transactionDate;
    
    private String description;
    
    // Optional order id from external payment system (e.g., CampostPay)
    @Column(name = "order_id")
    private String orderId;
    
    // Optional status synchronized with payment provider (PENDING, SUCCESS, FAILED)
    @Column(name = "status")
    private String status;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_id", nullable = false)
    private ServiceEntity service;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "structure_id", nullable = false)
    private Structure structure;
    
    @Column(name = "is_confirmed", nullable = false)
    private boolean isConfirmed = false;
    
    @Column(name = "confirmation_date")
    private LocalDate confirmationDate;
    
    // Méthodes utilitaires
    public void confirm() {
        this.isConfirmed = true;
        this.confirmationDate = LocalDate.now();
        this.status = "SUCCESS";
    }
    
    public void cancel() {
        this.isConfirmed = false;
        this.confirmationDate = null;
        this.status = "FAILED";
    }
}
