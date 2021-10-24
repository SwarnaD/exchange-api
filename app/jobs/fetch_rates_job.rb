class FetchRatesJob < ApplicationJob
  queue_as :default
  after_perform do |job|
    # start the next job either when there is an update or relatively soon if there is no data
    next_update_time = Rails.cache.read('exchange_next_update')
    self.class.set(wait_until: next_update_time).perform_later
  end

  def perform(*guests)
    url = URI.parse(API_FULL_URL)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http| http.request(req) }
    failed_fetch = false
    if res.is_a?(Net::HTTPSuccess) and (exchange_data = JSON.parse(res.body))['result'] == 'success'
      # if the response is a success, save the rates, last update time, and next update time to the cache
      Rails.cache.write('exchange_conversion_rates', exchange_data['rates'])
      Rails.cache.write('exchange_next_update', Time.at(exchange_data['time_next_update_unix']).utc)
      Rails.cache.write('exchange_last_update', Time.at(exchange_data['time_last_update_unix']).utc)
    else
      # retry a fetch relatively soon if request was unsuccessful
      Rails.cache.write('exchange_next_update', Time.now.advance(seconds: SECONDS_TO_RETRY_FETCH))
    end
  end
end