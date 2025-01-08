open PriceLib

let client = PriceLib.createClient()

// Appel de la fonction `getPrice` corrigé pour respecter les règles top-level
PriceLib.getPrice(
  client,
  "bitcoin",
  "usd",
  (data) => {
    Js.log({"Success": data})
  },
  (error) => {
    Js.log({"Error": error})
  },
)->ignore // Ajout de `ignore` pour indiquer que le résultat est volontairement ignoré



// Test avec l'API CoinMarketCap
 let clientCMC = PriceLib.createClientUrl("https://pro-api.coinmarketcap.com")
 PriceLib.getCMCPrice(clientCMC, "BTC", "USD", "8958b1e7-36e6-4335-9ff7-86f9da097128")

