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
