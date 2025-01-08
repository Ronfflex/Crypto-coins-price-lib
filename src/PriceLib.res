open Webapi



module PriceLib = {
  let createClient = (~baseUrl=Config.baseUrl, ~timeout=Config.defaultTimeout, ~retryAttempts=Config.defaultRetryAttempts, ()): Types.client => {
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
      ()
    )
  }

  let getPrice = (
    client: Types.client,
    cryptoId: string,
    vsCurrency: string,
    onSuccess: Types.priceData => unit,
    onError: string => unit,
  ): promise<unit> => {
    let endpoint = `${client.baseUrl}/simple/price?ids=${cryptoId}&vs_currencies=${vsCurrency}`

    Fetch.fetch(endpoint)
    ->Promise.then(Fetch.Response.text)
    ->Promise.then(text => {
      switch Js.Json.parseExn(text)->Js.Json.decodeObject {
      | Some(jsonDict) =>
        let maybePrice =
          Belt.Option.flatMap(Js.Dict.get(jsonDict, cryptoId), dataJson =>
            Belt.Option.flatMap(Js.Json.decodeObject(dataJson), dataDict =>
              Belt.Option.flatMap(Js.Dict.get(dataDict, vsCurrency), priceJson =>
                Js.Json.decodeNumber(priceJson)
              )
            )
          )

        switch maybePrice {
        | Some(price) =>
          onSuccess({
            price: price,
            timestamp: Js.Date.now(),
            symbol: `${cryptoId}/${vsCurrency}`,
          })
        | None =>
          onError("Failed to parse the price")
        }

        Promise.resolve()
      | None =>
        onError("Invalid JSON response")
        Promise.resolve()
      }
    })
    ->Promise.catch(_ => {
      onError("Failed to fetch data")
      Promise.resolve()
    })
  }

  let getPriceWithPromise = (
    client: Types.client,
    cryptoId: string,
    vsCurrency: string,
  ): promise<Types.result> => {
    Promise.make((resolve, _) => {
      getPrice(
        client,
        cryptoId,
        vsCurrency,
        (data) => resolve(Belt.Result.Ok(data)),
        (error) =>
          resolve(Belt.Result.Error(Types.UnexpectedError(error))), // Conversion de l'erreur string
      )
      ->ignore
    })
  }

  let formatData = (price, symbol, ccy) => {
    Belt.Option.forEach(Some(price), x => Js.log4(symbol, "price: ", x, ccy))
  }

  let getCMCPrice = (
    client: Types.client,
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
