package net.chompstation13.manifest;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

import java.text.DateFormat;
import java.util.Date;

@Configuration
@EnableCaching
@EnableScheduling
public class CacheConfig {
    public static final String SOCKET = "socket";

    @Bean
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager(SOCKET);
    }

    @CacheEvict(allEntries = true, value = {SOCKET})
    @Scheduled(fixedDelayString = "${ttl}", initialDelay = 1000)
    public void reportCacheEvict() {
        System.out.println("Flush Cache " + DateFormat.getTimeInstance().format(new Date()));
    }
}