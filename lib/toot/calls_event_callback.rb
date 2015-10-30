require 'net/http'

module Toot
  class CallsEventCallback
    include Sidekiq::Worker

    def perform(callback_url, event_data)
      uri = URI(callback_url)

      response = Toot.config.http_connection.post do |request|
        request.url uri
        request.body = event_data.to_json
        request.headers["Content-Type"] = "application/json"
      end

      if response.success?
        if response.headers["X-Toot-Unsubscribe"]
          Toot.redis do |r|
            r.srem event_data["channel"], callback_url
          end
        end
      else
        raise CallbackFailure, "Response code: #{response.status}"
      end
    end
  end
end
