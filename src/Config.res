/**
 * Configuration constants and defaults for the BTC price query library
 */
open Types

let defaultConfig: config = {
  baseUrl: "https://api.coingecko.com/api/v3",
  timeout: 5000,
  retryAttempts: 3,
}

let defaultQueryOptions: queryOptions = {
  cacheDuration: Some(30), // 30 seconds default cache
  forceRefresh: false,
}

/** Maximum number of requests per minute */
let rateLimit = 60

/** Cache configuration */
let maxCacheSize = 1000 // Maximum number of cached items
let defaultCacheTtl = 30 // Default TTL in seconds

// Ajout des accès directs
let baseUrl = defaultConfig.baseUrl
let defaultTimeout = defaultConfig.timeout
let defaultRetryAttempts = defaultConfig.retryAttempts
