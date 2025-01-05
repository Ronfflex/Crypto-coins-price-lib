type cacheType = Js.Json.t // Type pour un objet JSON générique

type t = {
  api: Api.t,
  cache: Utils.Cache.t<cacheType, Types.priceData>,
  requestThrottle: unit => unit,
}

let make = (~config=Config.defaultConfig, ()): t => {
  let api = Api.createClient(~baseUrl=config.baseUrl, ~timeout=config.timeout, ~retryAttempts=config.retryAttempts, ())

  {
    api,
    cache: Utils.Cache.make(~ttl=Config.defaultCacheTtl, ()),
    requestThrottle: Utils.throttle(() => (), 60000 / Config.rateLimit),
  }
}

let getPrice = (
  client: t,
  cryptoId: string,
  vsCurrency: string,
  ~options=Config.defaultQueryOptions,
  (),
): promise<Types.result> => {
  let cacheKey = `${cryptoId}/${vsCurrency}`

  if !options.forceRefresh {
    switch client.cache->Utils.Cache.get(cacheKey) {
    | Some(data) =>
      Promise.resolve(Ok(data))
    | None => {
        client.requestThrottle()
        client.api
        ->Api.getCurrentPrice(cryptoId, vsCurrency)
        ->Promise.then(result => {
          switch result {
          | Ok(data) =>
            if options.cacheDuration->Option.isSome {
              client.cache->Utils.Cache.set(cacheKey, data)
            }
            Promise.resolve(Ok(data))
          | Error(_) as error => Promise.resolve(error)
          }
        })
      }
    }
  } else {
    client.requestThrottle()
    client.api
    ->Api.getCurrentPrice(cryptoId, vsCurrency)
    ->Promise.then(result => {
      switch result {
      | Ok(data) =>
        if options.cacheDuration->Option.isSome {
          client.cache->Utils.Cache.set(cacheKey, data)
        }
        Promise.resolve(Ok(data))
      | Error(_) as error => Promise.resolve(error)
      }
    })
  }
}
