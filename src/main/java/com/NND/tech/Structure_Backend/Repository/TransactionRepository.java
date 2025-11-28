package com.NND.tech.Structure_Backend.Repository;

import com.NND.tech.Structure_Backend.model.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    
    /**
     * Calcule le chiffre d'affaires total
     * @return le montant total des transactions
     */
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t")
    double getTotalRevenue();
    
    /**
     * Calcule le chiffre d'affaires pour une plage de dates
     * @param startDate date de début
     * @param endDate date de fin
     * @return le montant total des transactions dans l'intervalle
     */
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.transactionDate BETWEEN :startDate AND :endDate")
    double getTotalRevenueByDateRange(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
    
    /**
     * Calcule le chiffre d'affaires pour une structure spécifique
     * @param structureId l'ID de la structure
     * @return le montant total des transactions pour cette structure
     */
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.structure.id = :structureId")
    double getTotalRevenueByStructureId(@Param("structureId") Long structureId);
    
    /**
     * Compte le nombre de transactions pour une structure spécifique
     * @param structureId l'ID de la structure
     * @return le nombre de transactions pour cette structure
     */
    long countByStructureId(Long structureId);
    
    /**
     * Récupère les transactions entre deux dates
     * @param startDate date de début
     * @param endDate date de fin
     * @return liste des transactions dans l'intervalle
     */
    List<Transaction> findByTransactionDateBetween(LocalDate startDate, LocalDate endDate);
    
    /**
     * Compte le nombre de transactions entre deux dates
     * @param startDate date de début
     * @param endDate date de fin
     * @return le nombre de transactions dans l'intervalle
     */
    long countByTransactionDateBetween(LocalDate startDate, LocalDate endDate);
    
    /**
     * Calcule le chiffre d'affaires pour une catégorie spécifique dans une plage de dates
     * @param category la catégorie de service
     * @param startDate date de début
     * @param endDate date de fin
     * @return le montant total des transactions pour cette catégorie dans l'intervalle
     */
    @Query("""
        SELECT COALESCE(SUM(t.amount), 0) 
        FROM Transaction t 
        WHERE t.service.category = :category 
        AND t.transactionDate BETWEEN :startDate AND :endDate
    """)
    double getTotalRevenueByCategoryAndDateRange(
            @Param("category") String category,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
    
    /**
     * Récupère les transactions pour une structure spécifique
     * @param structureId l'ID de la structure
     * @return liste des transactions pour cette structure
     */
    List<Transaction> findByStructureId(Long structureId);

    java.util.Optional<Transaction> findFirstByOrderId(String orderId);
}
