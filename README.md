# Exchange API

## Description
A service to convert currencies.

## Usage 

### Convert
`GET https://guarded-earth-69779.herokuapp.com/<amount>/<currency_to_convert_from>/<currency_to_convert_to>`

### Get Rates
`GET https://guarded-earth-69779.herokuapp.com/rates`

## Examples


* `GET https://guarded-earth-69779.herokuapp.com/5/usd/cad`

```json
{
  "success": "true",
  "update": {
    "last_update": "2021-10-24T00:02:31.000+00:00",
    "next_update": "2021-10-25T00:33:01.000+00:00"
  },
  "payload": {
    "result": "$7.38",
    "result_raw": "7.38",
    "symbol": "$"
  }
}

```

* `GET https://guarded-earth-69779.herokuapp.com/20.57/gbp/JPY`

```json
{
  "success": "true",
  "update": {
    "last_update": "2021-10-24T00:02:31.000+00:00",
    "next_update": "2021-10-25T00:34:21.000+00:00"
  },
  "payload": {
    "result": "¥3,227",
    "result_raw": "3227",
    "symbol": "¥"
  }
}
```

* `GET https://guarded-earth-69779.herokuapp.com/rates`

```json
{
  "success": "true",
  "update": {
    "last_update": "2021-10-24T00:02:31.000+00:00",
    "next_update": "2021-10-25T00:33:01.000+00:00"
  },
  "payload": {
    "result": {
      "USD": 1,
      "AED": 3.67,
      "AFN": 84.95,
      "ALL": 104.72,
      "AMD": 477.87,
      "ANG": 1.79,
      "AOA": 603.48,
      "ARS": 99.45,
      "AUD": 1.34,
      "AWG": 1.79,
      "AZN": 1.7,
      "...": "..."
    }
  }
}

