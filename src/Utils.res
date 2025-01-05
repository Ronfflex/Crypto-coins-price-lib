/**
 * Utility functions for the BTC price query library
 */
type lruCacheOptions = {
  max: int,
  ttl: int,
}

/** Importation de l'export nommé depuis `lru-cache` */
@module("lru-cache") @new external createLRUCache: lruCacheOptions => 'cache = "LRUCache";

/** Module Cache */
module Cache = {
  type t<'cache, 'value> = {cache: 'cache}

  let make = (~ttl: int, ~max=Config.maxCacheSize, ()): t<'cache, 'value> => {
    let options = {
      max,
      ttl: ttl * 1000, // Convert to milliseconds
    }
    {cache: createLRUCache(options)}
  }

  @send external set: ('cache, string, 'value) => unit = "set";
  @send external get: ('cache, string) => Nullable.t<'value> = "get";
  @send external clear: 'cache => unit = "clear";

  let set = (cache: t<'cache, 'value>, key: string, value: 'value): unit => {
    set(cache.cache, key, value)
  }

  let get = (cache: t<'cache, 'value>, key: string): option<'value> => {
    get(cache.cache, key)
    |> Js.Nullable.toOption
  }

  let clear = (cache: t<'cache, 'value>): unit => {
    clear(cache.cache)
  }
}
/**
 * Validates a price value
 */
let isValidPrice = (price: float): bool => {
  price > 0.0 && !Js.Float.isNaN(price) && Js.Float.isFinite(price)
}

/**
 * Creates a throttled version of a function that can only be called once within a given time window
 */
let throttle = (fn: unit => unit, timeWindow: int): (unit => unit) => {
  let lastCall = ref(None)

  () => {
    let now = Js.Date.now()

    switch lastCall.contents {
    | None => {
        lastCall := Some(now)
        fn()
      }
    | Some(last) =>
      if now -. last > float_of_int(timeWindow) {
        lastCall := Some(now)
        fn()
      }
    }
  }
}

/**
 * Implements retry logic with exponential backoff
 */
let rec retry = (operation: unit => promise<'a>, ~attempts: int, ~delay: int): promise<'a> => {
  operation()->Promise.catch(error => {
    if attempts > 1 {
      Promise.make((resolve, _) => {
        let _ = setTimeout(
          () => {
            resolve(retry(operation, ~attempts=attempts - 1, ~delay=delay * 2))
          },
          delay,
        )
      })->Promise.then(x => x)
    } else {
      Promise.reject(error)
    }
  })
}
