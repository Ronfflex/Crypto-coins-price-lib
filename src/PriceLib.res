open Webapi


module PriceLib = {
  let createClient = (~baseUrl=Config.baseUrl, ~timeout=Config.defaultTimeout, ~retryAttempts=Config.defaultRetryAttempts, ()): Api.client => {
    {
      baseUrl,
      timeout,
      retryAttempts,
    }
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
}
