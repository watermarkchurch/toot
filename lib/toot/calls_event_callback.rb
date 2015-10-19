require 'net/http'

module Toot
  class CallsEventCallback
    include Sidekiq::Worker

    def perform(callback_url, payload)
      uri = URI(callback_url)
      request = Net::HTTP::Post.new(uri)
      request.body = payload.to_json
      request.content_type = "application/json"

      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request request
      end

      case response
      when Net::HTTPSuccess
      else
        raise CallbackFailure, "Response code: #{response.code}"
      end
    end
  end
end
