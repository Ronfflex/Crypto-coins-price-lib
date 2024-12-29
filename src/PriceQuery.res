/**
 * Main price query implementation with caching and retry logic
 */
type cacheType // Abstract type for the cache implementation

type t = {
  api: Api.t,
  cache: Utils.Cache.t<cacheType, Types.priceData>,
  requestThrottle: unit => unit,
}

/**
 * Creates a new price query instance
 */
let make = (~config=Config.defaultConfig, ()): t => {
  let api = Api.make(config)

  {
    api,
    cache: Utils.Cache.make(~ttl=Config.defaultCacheTtl, ()),
    requestThrottle: Utils.throttle(() => (), 60000 / Config.rateLimit),
  }
}

/**
 * Fetches the current BTC/USDT price with caching and retry logic
 */
let getPrice = (client: t, ~options=Config.defaultQueryOptions, ()): promise<Types.result> => {
  // Check cache first unless force refresh is requested
  if !options.forceRefresh {
    switch client.cache->Utils.Cache.get("BTC/USDT") {
    | Some(data) => Promise.resolve(Ok(data))
    | None => {
        // Cache miss or expired, proceed with API call
        client.requestThrottle()
        client.api
        ->Api.getCurrentPrice
        ->Promise.then(result => {
          switch result {
          | Ok(data) =>
            switch options.cacheDuration {
            | Some(_) => client.cache->Utils.Cache.set("BTC/USDT", data)
            | None => ()
            }
            Promise.resolve(Ok(data))
          | Error(_) as error => Promise.resolve(error)
          }
        })
      }
    }
  } else {
    // Force refresh requested, skip cache
    client.requestThrottle()
    client.api
    ->Api.getCurrentPrice
    ->Promise.then(result => {
      switch result {
      | Ok(data) =>
        switch options.cacheDuration {
        | Some(_) => client.cache->Utils.Cache.set("BTC/USDT", data)
        | None => ()
        }
        Promise.resolve(Ok(data))
      | Error(_) as error => Promise.resolve(error)
      }
    })
  }
}
