# fetch conversion rates
class FetchRatesJob < ApplicationJob
  queue_as :default
  after_perform do |job|
    # start the next fetch either when there is an update or relatively soon if there was no data
    next_update_time = Rails.cache.read('exchange_next_update')
    self.class.set(wait_until: next_update_time).perform_later
  end

  def perform(*guests)
    # fetch only if cache has no data OR an update is available
    if (not Rails.cache.read('exchange_conversion_rates')) or (Rails.cache.read('next_update') <= Time.now)
      url = URI.parse(API_FULL_URL)
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http| http.request(req) }
      failed_fetch = false

      # save rates and update times to cache if call to API is successful
      if res.is_a?(Net::HTTPSuccess) and (exchange_data = JSON.parse(res.body))['result'] == 'success'
        Rails.cache.write('exchange_conversion_rates', exchange_data['rates'])
        Rails.cache.write('exchange_next_update', Time.at(exchange_data['time_next_update_unix']).utc)
        Rails.cache.write('exchange_last_update', Time.at(exchange_data['time_last_update_unix']).utc)
      # retry a fetch relatively soon if request was unsuccessful
      else
        Rails.cache.write('exchange_next_update', Time.now.advance(seconds: SECONDS_TO_RETRY_FETCH))
      end
    end
  end
end