package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.DTO.StatsDto;
import com.NND.tech.Structure_Backend.Service.StatsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Contrôleur REST pour la gestion des statistiques de l'application.
 * Fournit des endpoints pour récupérer différentes métriques et indicateurs.
 */
@RestController
@RequestMapping("/api/stats")
@RequiredArgsConstructor
@Tag(name = "Statistics", description = "Endpoints pour la récupération des statistiques")
public class StatsController {

    private final StatsService statsService;

    /**
     * Récupère les statistiques globales de l'application.
     *
     * @return ResponseEntity contenant les statistiques globales
     */
    @GetMapping
    @Operation(
        summary = "Obtenir les statistiques globales",
        description = "Fournit un aperçu global des statistiques de l'application"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Statistiques récupérées avec succès",
                     content = @Content(schema = @Schema(implementation = StatsDto.class))),
        @ApiResponse(responseCode = "500", description = "Erreur interne du serveur")
    })
    public ResponseEntity<StatsDto> getGlobalStats() {
        return ResponseEntity.ok(statsService.getGlobalStats());
    }

    /**
     * Récupère les statistiques pour une plage de dates donnée.
     *
     * @param startDate Date de début de la plage (inclusive)
     * @param endDate Date de fin de la plage (inclusive)
     * @return ResponseEntity contenant les statistiques pour la plage de dates
     */
    @GetMapping("/by-date-range")
    @Operation(
        summary = "Obtenir les statistiques par plage de dates",
        description = "Fournit les statistiques pour une plage de dates spécifique"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Statistiques récupérées avec succès",
                     content = @Content(schema = @Schema(implementation = StatsDto.class))),
        @ApiResponse(responseCode = "400", description = "Requête invalide (dates invalides)"),
        @ApiResponse(responseCode = "500", description = "Erreur interne du serveur")
    })
    public ResponseEntity<StatsDto> getStatsByDateRange(
            @Parameter(description = "Date de début (format: yyyy-MM-dd)", required = true, example = "2023-01-01")
            @RequestParam 
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) 
            LocalDate startDate,
            
            @Parameter(description = "Date de fin (format: yyyy-MM-dd)", required = true, example = "2023-12-31")
            @RequestParam 
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) 
            LocalDate endDate) {
        return ResponseEntity.ok(statsService.getStatsByDateRange(startDate, endDate));
    }

    /**
     * Récupère les statistiques pour une structure spécifique.
     *
     * @param structureId L'identifiant de la structure
     * @return ResponseEntity contenant les statistiques de la structure
     */
    @GetMapping("/by-structure/{structureId}")
    @Operation(
        summary = "Obtenir les statistiques pour une structure spécifique",
        description = "Fournit les statistiques détaillées pour une structure particulière"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Statistiques récupérées avec succès",
                     content = @Content(schema = @Schema(implementation = StatsDto.class))),
        @ApiResponse(responseCode = "404", description = "Structure non trouvée"),
        @ApiResponse(responseCode = "500", description = "Erreur interne du serveur")
    })
    public ResponseEntity<StatsDto> getStatsByStructure(
            @Parameter(description = "ID de la structure", required = true, example = "1")
            @PathVariable Long structureId) {
        return ResponseEntity.ok(statsService.getStatsByStructure(structureId));
    }

    /**
     * Vide le cache des statistiques.
     *
     * @return ResponseEntity indiquant le succès de l'opération
     */
    @GetMapping("/clear-cache")
    @Operation(summary = "Vider le cache des statistiques",
               description = "Vide le cache des statistiques, forçant un recalcul aux prochaines requêtes")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Cache vidé avec succès"),
        @ApiResponse(responseCode = "500", description = "Erreur interne du serveur")
    })
    public ResponseEntity<Void> clearStatsCache() {
        statsService.clearStatsCache();
        return ResponseEntity.ok().build();
    }

    /**
     * Récupère les tendances de revenus sur une période donnée.
     *
     * @param startDate Date de début de la période
     * @param endDate Date de fin de la période
     * @param period Période de regroupement (daily, weekly, monthly)
     * @return Map des périodes avec les montants de revenus
     */
    @GetMapping("/revenue-trend")
    @Operation(
        summary = "Obtenir les tendances de revenus",
        description = "Fournit une évolution des revenus sur une période donnée avec un regroupement personnalisable"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Tendances récupérées avec succès",
                     content = @Content(schema = @Schema(implementation = Map.class))),
        @ApiResponse(responseCode = "400", description = "Paramètres de requête invalides"),
        @ApiResponse(responseCode = "500", description = "Erreur interne du serveur")
    })
    public ResponseEntity<Map<String, Double>> getRevenueTrend(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(defaultValue = "monthly") String period) {
        
        if (startDate.isAfter(endDate)) {
            throw new IllegalArgumentException("La date de début doit être antérieure à la date de fin");
        }
        
        if (!List.of("daily", "weekly", "monthly").contains(period.toLowerCase())) {
            throw new IllegalArgumentException("La période doit être 'daily', 'weekly' ou 'monthly'");
        }
        
        return ResponseEntity.ok(statsService.getRevenueTrend(startDate, endDate, period.toLowerCase()));
    }

    /**
     * Compare les statistiques entre deux périodes.
     *
     * @param firstPeriodStart Date de début de la première période
     * @param firstPeriodEnd Date de fin de la première période
     * @param secondPeriodStart Date de début de la deuxième période
     * @param secondPeriodEnd Date de fin de la deuxième période
     * @return Map contenant les statistiques comparées
     */
    @GetMapping("/compare-periods")
    @Operation(
        summary = "Comparer deux périodes",
        description = "Compare les performances entre deux périodes données"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Comparaison effectuée avec succès",
                     content = @Content(schema = @Schema(implementation = Map.class))),
        @ApiResponse(responseCode = "400", description = "Périodes invalides"),
        @ApiResponse(responseCode = "500", description = "Erreur interne du serveur")
    })
    public ResponseEntity<Map<String, Object>> comparePeriods(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate firstPeriodStart,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate firstPeriodEnd,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate secondPeriodStart,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate secondPeriodEnd) {
        
        if (firstPeriodStart.isAfter(firstPeriodEnd) || secondPeriodStart.isAfter(secondPeriodEnd)) {
            throw new IllegalArgumentException("Les dates de début doivent être antérieures aux dates de fin");
        }
        
        return ResponseEntity.ok(statsService.comparePeriods(
            firstPeriodStart, firstPeriodEnd, secondPeriodStart, secondPeriodEnd));
    }

    /**
     * Récupère les structures les plus performantes par revenus.
     *
     * @param limit Nombre maximum de structures à retourner (par défaut 5)
     * @return Liste des structures avec leurs statistiques de performance
     */
    @GetMapping("/top-structures")
    @Operation(
        summary = "Obtenir les structures les plus performantes",
        description = "Liste les structures générant le plus de revenus"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Structures récupérées avec succès",
                     content = @Content(array = @ArraySchema(schema = @Schema(implementation = Map.class)))),
        @ApiResponse(responseCode = "500", description = "Erreur interne du serveur")
    })
    public ResponseEntity<List<Map<String, Object>>> getTopPerformingStructures(
            @RequestParam(defaultValue = "5") int limit) {
        
        if (limit <= 0) {
            limit = 5;
        }
        
        return ResponseEntity.ok(statsService.getTopPerformingStructures(limit));
    }

    /**
     * Récupère la répartition des revenus par catégorie.
     *
     * @param startDate Date de début de la période
     * @param endDate Date de fin de la période
     * @return Map des catégories avec leurs revenus respectifs
     */
    @GetMapping("/revenue-by-category")
    @Operation(
        summary = "Obtenir la répartition des revenus par catégorie",
        description = "Fournit une ventilation des revenus par catégorie de service/produit"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Répartition récupérée avec succès",
                     content = @Content(schema = @Schema(implementation = Map.class))),
        @ApiResponse(responseCode = "400", description = "Période invalide"),
        @ApiResponse(responseCode = "500", description = "Erreur interne du serveur")
    })
    public ResponseEntity<Map<String, Double>> getRevenueByCategory(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        
        if (startDate.isAfter(endDate)) {
            throw new IllegalArgumentException("La date de début doit être antérieure à la date de fin");
        }
        
        return ResponseEntity.ok(statsService.getRevenueByCategory(startDate, endDate));
    }
}
