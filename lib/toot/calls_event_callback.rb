require 'net/http'

module Toot
  class CallsEventCallback
    include Sidekiq::Worker

    def perform(callback_url, event_data)
      uri = URI(callback_url)
      request = Net::HTTP::Post.new(uri)
      request.body = event_data.to_json
      request.content_type = "application/json"

      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request Toot.config.request_filter.(request)
      end

      case response
      when Net::HTTPSuccess
        if response["X-Toot-Unsubscribe"]
          Toot.redis do |r|
            r.srem event_data["channel"], callback_url
          end
        end
      else
        raise CallbackFailure, "Response code: #{response.code}"
      end
    end
  end
end
