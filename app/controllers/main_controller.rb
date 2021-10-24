class MainController < ApplicationController
  def calculate
    response = {}
    from = params[:from_currency].upcase
    to = params[:to_currency].upcase

    begin
      amount = BigDecimal(params[:amount])
    rescue ArgumentError
      response['status'] = 'invalid amount'
      render json: response.to_json and return
    end
  
    conversion_rates = Rails.cache.read('exchange_conversion_rates')

    if conversion_rates.nil?
      response['status'] = 'no data'
      render json: response.to_json and return
    end

    if not (conversion_rates[from] and conversion_rates[to])
      response['status'] = 'unsupported currency'
      render json: response.to_json and return
    end

    from_rate = BigDecimal(conversion_rates[from].to_s)
    to_rate = BigDecimal(conversion_rates[to].to_s)

    Money.add_rate(from, to, to_rate/from_rate)
    result = Money.from_amount(amount, from).exchange_to(to)

    response['result'] = result.format
    response['result_raw'] = result.format(symbol: false, thousands_separator: false)
    response['symbol'] = result.format(format: '%u')
    response['last_update'] = Rails.cache.read('exchange_last_update').to_datetime
    response['next_update'] = Rails.cache.read('exchange_next_update').to_datetime
    response['status'] = 'success'
    render json: response.to_json and return
  end

  def rates
    conversion_rates = Rails.cache.read('exchange_conversion_rates')

    if conversion_rates.nil?
      response['status'] = 'no data'
      render json: response.to_json and return
    end

    response['result'] = conversion_rates
    response['last_update'] = Rails.cache.read('exchange_last_update').to_datetime
    response['next_update'] = Rails.cache.read('exchange_next_update').to_datetime

    render json: response.to_json and return
  end
end
