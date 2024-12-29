// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Utils from "./Utils.res.mjs";
import * as Config from "./Config.res.mjs";
import * as Js_dict from "rescript/lib/es6/js_dict.js";
import * as Js_json from "rescript/lib/es6/js_json.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Promise from "@rescript/core/src/Core__Promise.res.mjs";
import * as Webapi__Fetch from "rescript-webapi/src/Webapi/Webapi__Fetch.res.mjs";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";

function defaultHeaders() {
  var headers = {};
  headers["Accept"] = "application/json";
  return headers;
}

function make(config) {
  return {
          config: config,
          cache: Utils.Cache.make(Config.defaultCacheTtl, undefined, undefined)
        };
}

function parseResponse(text) {
  try {
    var json = JSON.parse(text);
    var obj = Js_json.decodeObject(json);
    if (obj === undefined) {
      return {
              TAG: "Error",
              _0: "Invalid JSON object"
            };
    }
    var price = Js_dict.get(obj, "price");
    if (price === undefined) {
      return {
              TAG: "Error",
              _0: "Missing price field"
            };
    }
    var priceValue = Js_json.decodeNumber(price);
    if (priceValue !== undefined && Utils.isValidPrice(priceValue)) {
      return {
              TAG: "Ok",
              _0: {
                price: priceValue,
                timestamp: Date.now(),
                symbol: "BTC/USDT"
              }
            };
    } else {
      return {
              TAG: "Error",
              _0: "Invalid price value"
            };
    }
  }
  catch (exn){
    return {
            TAG: "Error",
            _0: "Failed to parse JSON"
          };
  }
}

function mapError(error) {
  if (error === "Network error") {
    return {
            TAG: "NetworkError",
            _0: error
          };
  } else {
    return {
            TAG: "InvalidResponse",
            _0: error
          };
  }
}

function getCurrentPrice(client) {
  return Core__Promise.$$catch(fetch(client.config.baseUrl.concat("/v1/btc-price"), Webapi__Fetch.RequestInit.make("Get", Caml_option.some(defaultHeaders()), undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)).then(function (prim) {
                    return prim.text();
                  }).then(function (res) {
                  var parsedData = parseResponse(res);
                  if (parsedData.TAG === "Ok") {
                    return Promise.resolve({
                                TAG: "Ok",
                                _0: parsedData._0
                              });
                  } else {
                    return Promise.resolve({
                                TAG: "Error",
                                _0: mapError(parsedData._0)
                              });
                  }
                }), (function (err) {
                var jsExn = Caml_js_exceptions.as_js_exn(err);
                var error;
                if (jsExn !== undefined) {
                  var msg = Caml_option.valFromOption(jsExn).message;
                  error = msg !== undefined ? ({
                        TAG: "NetworkError",
                        _0: msg
                      }) : ({
                        TAG: "UnexpectedError",
                        _0: "Unknown error occurred"
                      });
                } else {
                  error = {
                    TAG: "UnexpectedError",
                    _0: "Failed to fetch price"
                  };
                }
                return Promise.resolve({
                            TAG: "Error",
                            _0: error
                          });
              }));
}

export {
  defaultHeaders ,
  make ,
  parseResponse ,
  mapError ,
  getCurrentPrice ,
}
/* Utils Not a pure module */