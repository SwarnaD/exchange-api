class MainController < ApplicationController
  # calculate conversion of currency
  def calculate
    response = {}
    from = params[:from_currency].upcase
    to = params[:to_currency].upcase

    conversion_rates = Rails.cache.read('exchange_conversion_rates')

    # no rate data
    if conversion_rates.nil?
      response['error'] = 'no data'
      response['success'] = 'false'
      render json: response.to_json, status: (:service_unavailable) and return
    end

    # invalid amount
    begin
      amount = BigDecimal(params[:amount])
    rescue ArgumentError
      response['error'] = 'invalid amount'
      response['success'] = 'false'
      render json: response.to_json, status: (:bad_request) and return
    end

    # invalid currency
    if not (conversion_rates[from] and conversion_rates[to])
      response['error'] = 'unsupported currency'
      response['success'] = 'false'
      render json: response.to_json, status: (:bad_request) and return
    end

    from_rate = BigDecimal(conversion_rates[from].to_s)
    to_rate = BigDecimal(conversion_rates[to].to_s)

    # do conversion
    Money.add_rate(from, to, to_rate/from_rate)
    result = Money.from_amount(amount, from).exchange_to(to)

    response['success'] = 'true'

    payload = {}
    payload['result'] = result.format
    payload['result_raw'] = result.format(symbol: false, thousands_separator: false)
    payload['symbol'] = result.format(format: '%u')
    payload['last_update'] = Rails.cache.read('exchange_last_update').to_datetime
    payload['next_update'] = Rails.cache.read('exchange_next_update').to_datetime
    response['payload'] = payload

    render json: response.to_json, status: (:ok) and return
  end

  # return raw rates
  def rates
    response = {}
    conversion_rates = Rails.cache.read('exchange_conversion_rates')

    # rates are not yet populated
    if conversion_rates.nil?
      response['success'] = 'false'
      response['error'] = 'no data'
      render json: response.to_json, status: (:service_unavailable) and return
    end
    response['success'] = 'true'

    payload = {}
    payload['result'] = conversion_rates
    payload['last_update'] = Rails.cache.read('exchange_last_update').to_datetime
    payload['next_update'] = Rails.cache.read('exchange_next_update').to_datetime
    response['payload'] = payload

    render json: response.to_json, status: (:ok) and return
  end

  def rootRoute
    response = {}

    response['success'] = 'true'

    payload = {}
    payload['example'] = request.original_url + '5.00/USD/CAD'
    payload['usage'] = request.original_url + '{amount}/{currency_to_convert_from}/{currency_to_convert_to}'
    response['payload'] = payload

    render json: response.to_json, status: (:ok) and return
  end

  def badRoute
    response = {}

    response['success'] = 'false'
    response['error'] = 'invalid path'

    render json: response.to_json, status: (:bad_request) and return
  end

end
