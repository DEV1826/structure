package com.NND.tech.Structure_Backend.Service;

import com.NND.tech.Structure_Backend.config.CacheConfig;
import com.NND.tech.Structure_Backend.DTO.StatsDto;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.NND.tech.Structure_Backend.Repository.TransactionRepository;
import com.NND.tech.Structure_Backend.Repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;


@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class StatsServiceImpl implements StatsService {

    private final TransactionRepository transactionRepository;
    private final StructureRepository structureRepository;
    private final UserRepository userRepository;

    @Override
    @Cacheable(value = CacheConfig.STATS_CACHE, 
               key = "T(com.NND.tech.Structure_Backend.config.CacheConfig).GLOBAL_STATS_KEY")
    public StatsDto getGlobalStats() {
        long totalTransactions = transactionRepository.count();
        double totalRevenue = transactionRepository.getTotalRevenue();
        long totalStructures = structureRepository.count();
        long totalUsers = userRepository.count();
        
        return StatsDto.builder()
                .totalTransactions(totalTransactions)
                .totalRevenue(totalRevenue)
                .totalStructures(totalStructures)
                .totalUsers(totalUsers)
                .build();
    }

    @Override
    @Cacheable(value = CacheConfig.STATS_CACHE, 
               key = "T(com.NND.tech.Structure_Backend.config.CacheConfig).DATE_RANGE_STATS_KEY_PREFIX + #startDate.toString() + '_' + #endDate.toString()")
    public StatsDto getStatsByDateRange(LocalDate startDate, LocalDate endDate) {
        if (startDate.isAfter(endDate)) {
            throw new IllegalArgumentException("La date de début doit être antérieure à la date de fin");
        }

        long transactionsInPeriod = transactionRepository.countByTransactionDateBetween(startDate, endDate);
        double revenueInPeriod = transactionRepository.getTotalRevenueByDateRange(startDate, endDate);
        
        return StatsDto.builder()
                .transactionsInPeriod(transactionsInPeriod)
                .revenueInPeriod(revenueInPeriod)
                .build();
    }

    @Override
    @Cacheable(value = CacheConfig.STATS_CACHE, 
               key = "T(com.NND.tech.Structure_Backend.config.CacheConfig).STRUCTURE_STATS_KEY_PREFIX + #structureId")
    public StatsDto getStatsByStructure(Long structureId) {
        Structure structure = structureRepository.findById(structureId)
                .orElseThrow(() -> new IllegalArgumentException("Structure non trouvée avec l'ID : " + structureId));

        long transactionsCount = transactionRepository.countByStructureId(structureId);
        double totalRevenue = transactionRepository.getTotalRevenueByStructureId(structureId);
        
        return StatsDto.builder()
                .totalTransactions(transactionsCount)
                .totalRevenue(totalRevenue)
                .structureId(structureId)
                .structureName(structure.getName())
                .build();
    }

    @Override
    @CacheEvict(value = CacheConfig.STATS_CACHE, allEntries = true)
    public void clearStatsCache() {
        // La méthode est annotée avec @CacheEvict, donc le cache sera vidé automatiquement
    }
    
    @Override
    public Map<String, Double> getRevenueTrend(LocalDate startDate, LocalDate endDate, String period) {
        Map<String, Double> revenueTrend = new LinkedHashMap<>();
        long daysBetween = ChronoUnit.DAYS.between(startDate, endDate);
        
        if ("monthly".equalsIgnoreCase(period) && daysBetween > 31) {
            // Regroupement mensuel
            LocalDate current = startDate.withDayOfMonth(1);
            while (!current.isAfter(endDate)) {
                LocalDate monthStart = current;
                LocalDate monthEnd = current.plusMonths(1).minusDays(1);
                if (monthEnd.isAfter(endDate)) {
                    monthEnd = endDate;
                }
                
                double revenue = transactionRepository.getTotalRevenueByDateRange(monthStart, monthEnd);
                revenueTrend.put(monthStart.getMonth().toString() + " " + monthStart.getYear(), 
                               round(revenue, 2));
                current = current.plusMonths(1);
            }
        } else if ("weekly".equalsIgnoreCase(period) && daysBetween > 7) {
            // Regroupement hebdomadaire
            LocalDate current = startDate;
            while (!current.isAfter(endDate)) {
                LocalDate weekEnd = current.plusDays(6);
                if (weekEnd.isAfter(endDate)) {
                    weekEnd = endDate;
                }
                
                double revenue = transactionRepository.getTotalRevenueByDateRange(current, weekEnd);
                revenueTrend.put("Semaine du " + current, round(revenue, 2));
                current = current.plusWeeks(1);
            }
        } else {
            // Par défaut, journalier
            LocalDate current = startDate;
            while (!current.isAfter(endDate)) {
                double revenue = transactionRepository.getTotalRevenueByDateRange(current, current);
                if (revenue > 0) {
                    revenueTrend.put(current.toString(), round(revenue, 2));
                }
                current = current.plusDays(1);
            }
        }
        
        return revenueTrend;
    }
    
    @Override
    public Map<String, Object> comparePeriods(
            LocalDate firstPeriodStart, LocalDate firstPeriodEnd,
            LocalDate secondPeriodStart, LocalDate secondPeriodEnd) {
            
        Map<String, Object> comparison = new HashMap<>();
        
        // Statistiques pour la première période
        StatsDto firstPeriodStats = getStatsByDateRange(firstPeriodStart, firstPeriodEnd);
        // Statistiques pour la deuxième période
        StatsDto secondPeriodStats = getStatsByDateRange(secondPeriodStart, secondPeriodEnd);
        
        // Calcul des variations
        double revenueChange = calculatePercentageChange(
            firstPeriodStats.getRevenueInPeriod(), 
            secondPeriodStats.getRevenueInPeriod());
            
        double transactionsChange = calculatePercentageChange(
            (double) firstPeriodStats.getTransactionsInPeriod(), 
            (double) secondPeriodStats.getTransactionsInPeriod());
        
        comparison.put("firstPeriod", firstPeriodStats);
        comparison.put("secondPeriod", secondPeriodStats);
        comparison.put("revenueChange", revenueChange);
        comparison.put("transactionsChange", transactionsChange);
        
        return comparison;
    }
    
    @Override
    public List<Map<String, Object>> getTopPerformingStructures(int limit) {
        List<Structure> allStructures = structureRepository.findAll();
        
        return allStructures.stream()
            .map(structure -> {
                double revenue = transactionRepository.getTotalRevenueByStructureId(structure.getId());
                long transactionCount = transactionRepository.countByStructureId(structure.getId());
                
                Map<String, Object> structureStats = new HashMap<>();
                structureStats.put("id", structure.getId());
                structureStats.put("name", structure.getName());
                structureStats.put("revenue", round(revenue, 2));
                structureStats.put("transactionCount", transactionCount);
                
                return structureStats;
            })
            .filter(stats -> (double) stats.get("revenue") > 0)
            .sorted((s1, s2) -> Double.compare(
                (double) s2.get("revenue"), 
                (double) s1.get("revenue")))
            .limit(limit)
            .collect(Collectors.toList());
    }
    
    @Override
    public Map<String, Double> getRevenueByCategory(LocalDate startDate, LocalDate endDate) {
        // Implémentation simplifiée - à adapter selon votre modèle de données
        // Cette méthode suppose que vous avez un moyen de récupérer les revenus par catégorie
        Map<String, Double> revenueByCategory = new HashMap<>();
        
        // Exemple avec des catégories statiques - à remplacer par votre logique métier
        List<String> categories = Arrays.asList("Hébergement", "Restauration", "Divertissement", "Autres");
        
        for (String category : categories) {
            // Ici, vous devriez appeler votre repository pour obtenir le revenu par catégorie
            double revenue = transactionRepository.getTotalRevenueByCategoryAndDateRange(
                category, startDate, endDate);
            if (revenue > 0) {
                revenueByCategory.put(category, round(revenue, 2));
            }
        }
        
        return revenueByCategory;
    }
    
    // Méthodes utilitaires
    private double calculatePercentageChange(double oldValue, double newValue) {
        if (oldValue == 0) {
            return newValue == 0 ? 0 : 100.0;
        }
        return round(((newValue - oldValue) / Math.abs(oldValue)) * 100, 2);
    }
    
    private double round(double value, int places) {
        if (places < 0) throw new IllegalArgumentException();
        
        BigDecimal bd = BigDecimal.valueOf(value);
        bd = bd.setScale(places, RoundingMode.HALF_UP);
        return bd.doubleValue();
    }
}
