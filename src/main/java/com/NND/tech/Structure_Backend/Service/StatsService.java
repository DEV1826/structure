package com.NND.tech.Structure_Backend.Service;

import com.NND.tech.Structure_Backend.config.CacheConfig;
import com.NND.tech.Structure_Backend.DTO.StatsDto;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface StatsService {
    /**
     * Récupère les statistiques globales de l'application
     * @return DTO contenant les statistiques globales
     */
    @Cacheable(value = CacheConfig.STATS_CACHE, key = "T(com.NND.tech.Structure_Backend.config.CacheConfig).GLOBAL_STATS_KEY")
    StatsDto getGlobalStats();
    
    /**
     * Récupère les statistiques sur une plage de dates donnée
     * @param startDate Date de début de la période
     * @param endDate Date de fin de la période
     * @return DTO contenant les statistiques pour la période spécifiée
     * @throws IllegalArgumentException si la date de début est postérieure à la date de fin
     */
    @Cacheable(value = CacheConfig.STATS_CACHE, 
               key = "T(com.NND.tech.Structure_Backend.config.CacheConfig).DATE_RANGE_STATS_KEY_PREFIX + #startDate.toString() + '_' + #endDate.toString()")
    StatsDto getStatsByDateRange(LocalDate startDate, LocalDate endDate);
    
    /**
     * Récupère les statistiques pour une structure spécifique
     * @param structureId Identifiant de la structure
     * @return DTO contenant les statistiques de la structure
     * @throws IllegalArgumentException si aucune structure n'est trouvée avec l'ID fourni
     */
    @Cacheable(value = CacheConfig.STATS_CACHE, 
               key = "T(com.NND.tech.Structure_Backend.config.CacheConfig).STRUCTURE_STATS_KEY_PREFIX + #structureId")
    StatsDto getStatsByStructure(Long structureId);
    
    /**
     * Vide le cache des statistiques
     */
    @CacheEvict(value = CacheConfig.STATS_CACHE, allEntries = true)
    void clearStatsCache();
    
    /**
     * Obtient les tendances de revenus sur une période donnée
     * @param startDate Date de début
     * @param endDate Date de fin
     * @param period Période de regroupement (daily, weekly, monthly)
     * @return Map des dates/périodes avec les montants de revenus
     */
    Map<String, Double> getRevenueTrend(LocalDate startDate, LocalDate endDate, String period);
    
    /**
     * Compare les statistiques entre deux périodes
     * @param firstPeriodStart Début de la première période
     * @param firstPeriodEnd Fin de la première période
     * @param secondPeriodStart Début de la deuxième période
     * @param secondPeriodEnd Fin de la deuxième période
     * @return Map contenant les statistiques comparées et les variations
     */
    Map<String, Object> comparePeriods(
        LocalDate firstPeriodStart, LocalDate firstPeriodEnd,
        LocalDate secondPeriodStart, LocalDate secondPeriodEnd);
    
    /**
     * Obtient les structures les plus performantes par revenus
     * @param limit Nombre maximum de structures à retourner
     * @return Liste des structures avec leurs statistiques de performance
     */
    List<Map<String, Object>> getTopPerformingStructures(int limit);
    
    /**
     * Obtient la répartition des revenus par catégorie
     * @param startDate Date de début
     * @param endDate Date de fin
     * @return Map des catégories avec leurs revenus respectifs
     */
    Map<String, Double> getRevenueByCategory(LocalDate startDate, LocalDate endDate);
}
