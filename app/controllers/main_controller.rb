class MainController < ApplicationController
  # calculate conversion of currency
  def calculate
    response = _newResponse
    from = params[:from_currency].upcase
    to = params[:to_currency].upcase

    conversion_rates = Rails.cache.read('exchange_conversion_rates')

    # no rate data
    if conversion_rates.nil?
      _setError(response, 'no data')
      _setSuccess(response, false)
      render json: response.to_json, status: (:service_unavailable) and return
    end

    # invalid amount
    begin
      amount = BigDecimal(params[:amount])
    rescue ArgumentError
      _setError(response, 'invalid amount')
      _setSuccess(response, false)
      render json: response.to_json, status: (:bad_request) and return
    end

    # invalid currency
    if not (conversion_rates[from] and conversion_rates[to])
      _setError(response, 'unsupported currency')
      _setSuccess(response, false)
      render json: response.to_json, status: (:bad_request) and return
    end

    from_rate = BigDecimal(conversion_rates[from].to_s)
    to_rate = BigDecimal(conversion_rates[to].to_s)

    # do conversion
    Money.add_rate(from, to, to_rate/from_rate)
    result = Money.from_amount(amount, from).exchange_to(to)

    _setSuccess(response, true)
    _setUpdateData(response)
    _setData(response, 'result', result.format)
    _setData(response, 'result_raw', result.format(symbol: false, thousands_separator: false))
    _setData(response, 'symbol', result.format(format: '%u'))

    render json: response.to_json, status: (:ok) and return
  end

  # return raw rates
  def rates
    response = _newResponse
    conversion_rates = Rails.cache.read('exchange_conversion_rates')

    # rates are not yet populated
    if conversion_rates.nil?
      _setSuccess(response, false)
      _setError(response, 'no data')
      render json: response.to_json, status: (:service_unavailable) and return
    end

    _setSuccess(response, true)
    _setUpdateData(response)
    _setData(response, 'result', conversion_rates)

    render json: response.to_json, status: (:ok) and return
  end

  def rootRoute
    response = _newResponse

    _setSuccess(response, true)
    _setHelpData(response)

    render json: response.to_json, status: (:ok) and return
  end

  def badRoute
    response = _newResponse

    _setSuccess(response, false)
    _setError(response, 'invalid path')
    _setHelpData(response)

    render json: response.to_json, status: (:bad_request) and return
  end


  private
    def _setData(response, field, result)
      response['payload'][field] = result
    end

    def _setUpdateData(response)
      response['update']['last_update'] = Rails.cache.read('exchange_last_update').to_datetime
      response['update']['next_update'] = Rails.cache.read('exchange_next_update').to_datetime
    end

    def _setHelpData(response)
      response['help']['example'] = request.original_url + '5.00/USD/CAD'
      response['help']['usage'] = request.original_url + '{amount}/{currency_to_convert_from}/{currency_to_convert_to}'
    end

    def _setSuccess(response, success)
      response['success'] = success ? 'true' : 'false'
    end

    def _setError(response, error)
      response['error'] = error
    end

    def _newResponse()
      return Hash.new { |response, key| response[key] = {} }
    end
end
