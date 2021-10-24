# settings for API
SECONDS_TO_RETRY_FETCH = 5
API_FULL_URL = "https://open.exchangerate-api.com/v6/latest"


# settings for money gem
I18n.locale = :en
Money.locale_backend = :i18n
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN