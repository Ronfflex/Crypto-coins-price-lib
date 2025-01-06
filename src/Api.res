open Webapi
open Promise
open Types

type cacheType = Js.Json.t // Représente une valeur JSON générique

// Type du client API
type client = {
  baseUrl: string,
  timeout: int,
  retryAttempts: int,
}

type t = client

// Fonction pour créer un client API
let createClient = (
  ~baseUrl=Config.baseUrl,
  ~timeout=Config.defaultTimeout,
  ~retryAttempts=Config.defaultRetryAttempts,
  (),
): client => {
  {
    baseUrl,
    timeout,
    retryAttempts,
  }
}

// Fonction pour récupérer un prix
let getCurrentPrice = (client: client, cryptoId: string, vsCurrency: string): promise<Types.result> => {
  let endpoint = `/simple/price?ids=${cryptoId}&vs_currencies=${vsCurrency}`
  let url = client.baseUrl ++ endpoint

  Fetch.fetch(url)
  ->then(Fetch.Response.text)
  ->then(text => {
    switch Js.Json.parseExn(text)->Js.Json.decodeObject {
    | Some(json) =>
      switch Js.Dict.get(json, cryptoId) {
      | Some(cryptoData) =>
        switch Js.Json.decodeObject(cryptoData) {
        | Some(data) =>
          switch Js.Dict.get(data, vsCurrency) {
          | Some(priceJson) =>
            switch Js.Json.decodeNumber(priceJson) {
            | Some(price) =>
              let priceData: Types.priceData = {
                price: price,
                timestamp: Js.Date.now(),
                symbol: `${cryptoId}/${vsCurrency}`,
              }
              Promise.resolve(Ok(priceData))
            | None => Promise.resolve(Error(Types.InvalidResponse("Invalid price format")))
            }
          | None => Promise.resolve(Error(Types.InvalidResponse("Currency not found in response")))
          }
        | None => Promise.resolve(Error(Types.InvalidResponse("Invalid crypto data format")))
        }
      | None => Promise.resolve(Error(Types.InvalidResponse("Crypto ID not found in response")))
      }
    | None => Promise.resolve(Error(Types.InvalidResponse("Invalid JSON response")))
    }
  })
  ->catch(_ => Promise.resolve(Error(Types.NetworkError("Failed to fetch data"))))
}
