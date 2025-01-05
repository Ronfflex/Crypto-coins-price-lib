/**
 * Core type definitions for the BTC price query library
 */
/** Represents price data from the exchange */
type priceData = {
  price: float,
  timestamp: float,
  symbol: string,
}

type client = {
  baseUrl: string,
  timeout: int,
  retryAttempts: int,
}

/** Possible error states during price fetching */
type error =
  | NetworkError(string)
  | InvalidResponse(string)
  | RateLimitExceeded
  | UnexpectedError(string)

/** Result type for price operations */
type result = Belt.Result.t<priceData, error>

/** Configuration for the price query client */
type config = {
  baseUrl: string,
  timeout: int,
  retryAttempts: int,
}

/** Options for price queries */
type queryOptions = {
  cacheDuration: option<int>,
  forceRefresh: bool,
}
