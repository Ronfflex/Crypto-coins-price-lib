/**
 * API client implementation for BTC price queries
 */
open Webapi
open Promise

type cacheType // Abstract type for the cache implementation

type t = {
  config: Types.config,
  cache: Utils.Cache.t<cacheType, Types.priceData>,
}

let defaultHeaders = () => {
  let headers = Dict.make()
  Dict.set(headers, "Accept", "application/json")
  headers
}

/**
 * Creates a new API client instance
 */
let make = (config: Types.config): t => {
  config,
  cache: Utils.Cache.make(~ttl=Config.defaultCacheTtl, ()),
}

/**
 * Validates and transforms raw API response data
 */
let parseResponse = (text: string): Belt.Result.t<Types.priceData, string> => {
  try {
    let json = Js.Json.parseExn(text)
    switch Js.Json.decodeObject(json) {
    | Some(obj) =>
      switch Js.Dict.get(obj, "price") {
      | Some(price) =>
        switch Js.Json.decodeNumber(price) {
        | Some(priceValue) if Utils.isValidPrice(priceValue) =>
          Ok({
            price: priceValue,
            timestamp: Js.Date.now(),
            symbol: "BTC/USDT",
          })
        | _ => Error("Invalid price value")
        }
      | None => Error("Missing price field")
      }
    | None => Error("Invalid JSON object")
    }
  } catch {
  | _ => Error("Failed to parse JSON")
  }
}

/**
 * Converts parsing errors to our Types.error type
 */
let mapError = (error: string): Types.error => {
  switch error {
  | "Network error" => Types.NetworkError(error)
  | _ => Types.InvalidResponse(error)
  }
}

/**
 * Fetches current BTC/USDT price from the exchange
 */
let getCurrentPrice = (client: t): promise<Types.result> => {
  let endpoint = "/v1/btc-price"

  Fetch.fetchWithInit(
    String.concat(client.config.baseUrl, endpoint),
    Fetch.RequestInit.make(
      ~method_=Get,
      ~headers=Fetch.HeadersInit.makeWithDict(defaultHeaders()),
      (),
    ),
  )
  ->then(Fetch.Response.text)
  ->then(res => {
    switch parseResponse(res) {
    | Ok(parsedData) => Promise.resolve(Ok(parsedData))
    | Error(parseError) => Promise.resolve(Error(mapError(parseError)))
    }
  })
  ->catch(err => {
    let error = switch Js.Exn.asJsExn(err) {
    | Some(jsExn) =>
      switch Js.Exn.message(jsExn) {
      | Some(msg) => Types.NetworkError(msg)
      | None => Types.UnexpectedError("Unknown error occurred")
      }
    | None => Types.UnexpectedError("Failed to fetch price")
    }
    Promise.resolve(Error(error))
  })
}
