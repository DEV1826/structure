package com.NND.tech.Structure_Backend.DTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StatsDto {
    private Long totalTransactions;
    private Double totalRevenue;
    private Long totalStructures;
    private Long totalUsers;
    
    // Pour les statistiques par période
    private Long transactionsInPeriod;
    private Double revenueInPeriod;
    
    // Pour les statistiques par structure
    private Long structureId;
    private String structureName;
    
    // Méthodes utilitaires
    public static StatsDtoBuilder builder() {
        return new StatsDtoBuilder();
    }
    
    public static class StatsDtoBuilder {
        private Long totalTransactions = 0L;
        private Double totalRevenue = 0.0;
        private Long totalStructures = 0L;
        private Long totalUsers = 0L;
        private Long transactionsInPeriod = 0L;
        private Double revenueInPeriod = 0.0;
        private Long structureId;
        private String structureName;
        
        public StatsDtoBuilder totalTransactions(Long totalTransactions) {
            this.totalTransactions = totalTransactions != null ? totalTransactions : 0L;
            return this;
        }
        
        public StatsDtoBuilder totalRevenue(Double totalRevenue) {
            this.totalRevenue = totalRevenue != null ? totalRevenue : 0.0;
            return this;
        }
        
        public StatsDtoBuilder totalStructures(Long totalStructures) {
            this.totalStructures = totalStructures != null ? totalStructures : 0L;
            return this;
        }
        
        public StatsDtoBuilder totalUsers(Long totalUsers) {
            this.totalUsers = totalUsers != null ? totalUsers : 0L;
            return this;
        }
        
        public StatsDtoBuilder transactionsInPeriod(Long transactionsInPeriod) {
            this.transactionsInPeriod = transactionsInPeriod != null ? transactionsInPeriod : 0L;
            return this;
        }
        
        public StatsDtoBuilder revenueInPeriod(Double revenueInPeriod) {
            this.revenueInPeriod = revenueInPeriod != null ? revenueInPeriod : 0.0;
            return this;
        }
        
        public StatsDtoBuilder structureId(Long structureId) {
            this.structureId = structureId;
            return this;
        }
        
        public StatsDtoBuilder structureName(String structureName) {
            this.structureName = structureName;
            return this;
        }
        
        public StatsDto build() {
            StatsDto statsDto = new StatsDto();
            // Assign fields directly to avoid reliance on Lombok-generated setters
            statsDto.totalTransactions = this.totalTransactions;
            statsDto.totalRevenue = this.totalRevenue;
            statsDto.totalStructures = this.totalStructures;
            statsDto.totalUsers = this.totalUsers;
            statsDto.transactionsInPeriod = this.transactionsInPeriod;
            statsDto.revenueInPeriod = this.revenueInPeriod;
            statsDto.structureId = this.structureId;
            statsDto.structureName = this.structureName;
            return statsDto;
        }
    }
}
