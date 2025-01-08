open PriceLib

let client = PriceLib.createClient()

PriceLib.getPrice(
  client,
  "bitcoin",
  "usd",
  (data) => {
    Js.log({
      "message": "Success",
      "data": data,
    })
  },
  (error) => {
    Js.log({
      "message": "Error",
      "error": error,
    })
  },
)
// Test avec l'API CoinMarketCap
let clientCMC = PriceLib.createClientUrl("https://pro-api.coinmarketcap.com");
Js.log("------------ TEST getCMCPrice ----------------")
let price = PriceLib.getCMCPrice(clientCMC, "BTC", "USD", "8958b1e7-36e6-4335-9ff7-86f9da097128");



