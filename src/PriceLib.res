open Webapi


module PriceLib = {
  let createClient = (~baseUrl=Config.baseUrl, ~timeout=Config.defaultTimeout, ~retryAttempts=Config.defaultRetryAttempts, ()): Api.client => {
    {
      baseUrl,
      timeout,
      retryAttempts,
    }
  }

  let createClientUrl = (baseUrl) => {
    createClient(
    ~baseUrl=baseUrl,
    ~timeout=Config.defaultTimeout,
    ~retryAttempts=Config.defaultRetryAttempts,
    ())
  } 
  


  let getPrice = (
    client: Api.client,
    cryptoId: string,
    vsCurrency: string,
    onSuccess: Types.priceData => unit,
    onError: string => unit,
  ) => {
    let endpoint = `${client.baseUrl}/simple/price?ids=${cryptoId}&vs_currencies=${vsCurrency}`

    Fetch.fetch(endpoint)
    ->Promise.then(Fetch.Response.text)
    ->Promise.then(text => {
      switch Js.Json.parseExn(text)->Js.Json.decodeObject {
      | Some(json) =>
        switch Js.Dict.get(json, cryptoId) {
        | Some(dataJson) =>
          switch Js.Json.decodeObject(dataJson) {
          | Some(dataDict) =>
            switch Js.Dict.get(dataDict, vsCurrency) {
            | Some(priceJson) =>
              switch Js.Json.decodeNumber(priceJson) {
              | Some(price) =>
                Promise.resolve(
                  onSuccess({
                    price: price,
                    timestamp: Js.Date.now(),
                    symbol: `${cryptoId}/${vsCurrency}`,
                  }),
                )
              | None => Promise.resolve(onError("Invalid price format"))
              }
            | None => Promise.resolve(onError("Currency not found in response"))
            }
          | None => Promise.resolve(onError("Invalid crypto data format"))
          }
        | None => Promise.resolve(onError("Crypto ID not found in response"))
        }
      | None => Promise.resolve(onError("Invalid JSON response"))
      }
    })
    ->Promise.catch(_ => {
      onError("Failed to fetch data")
      Promise.resolve()
    })
    ->ignore
  }

  let formatData = (price, symbol, ccy) => {
    Belt.Option.forEach(Some(price), x => Js.log4(symbol, "price: ", x, ccy))
  }

  let getCMCPrice = (
    client: Api.client,
    cryptoSymbol: string,
    currency: string,
    api_key: string
  ) => {
 
  let endpoint = client.baseUrl ++ "/v1/cryptocurrency/quotes/latest?convert=" ++ currency ++ "&symbol=" ++ cryptoSymbol

  Fetch.fetchWithInit(
  endpoint,
  Fetch.RequestInit.make(
    ~method_=Get,
    ~headers=Fetch.HeadersInit.make({
      "Accepts": "application/json",
      "X-CMC_PRO_API_KEY": api_key,
    }),
    (),
  ),
)->Promise.then(Fetch.Response.json)
->Promise.then(json => {
  json
  ->Js.Json.decodeObject
  ->Belt.Option.flatMap(jsonObject =>
    Js.Dict.get(jsonObject, "data")
  )
  ->Belt.Option.flatMap(Js.Json.decodeObject)
  ->Belt.Option.flatMap(dataObj =>
    Js.Dict.get(dataObj, "BTC")
  )
  ->Belt.Option.flatMap(Js.Json.decodeObject)
  ->Belt.Option.flatMap(symbol =>
    Js.Dict.get(symbol, "quote")
  )
  ->Belt.Option.flatMap(Js.Json.decodeObject)
  ->Belt.Option.flatMap(quoteObj =>
    Js.Dict.get(quoteObj, "USD")
  )
  ->Belt.Option.flatMap(Js.Json.decodeObject)
  ->Belt.Option.flatMap(ccyObj =>
    Js.Dict.get(ccyObj, "price")
  )
  ->Belt.Option.map(price => {
    formatData(price, cryptoSymbol, currency)
  })
  ->Belt.Option.getWithDefault(())
  Promise.resolve(())
})
->Promise.catch(_error => {
  Js.log("Failed to fetch data")
  Promise.resolve(())
})
->ignore

}
}
