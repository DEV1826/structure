package com.NND.tech.Structure_Backend.config;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableCaching
public class CacheConfig {

    public static final String STATS_CACHE = "statsCache";
    public static final String GLOBAL_STATS_KEY = "globalStats";
    public static final String STRUCTURE_STATS_KEY_PREFIX = "structureStats_";
    public static final String DATE_RANGE_STATS_KEY_PREFIX = "dateRangeStats_";

    @Bean
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager(
            STATS_CACHE,
            "structures",
            "services",
            "transactions"
        );
    }
}
