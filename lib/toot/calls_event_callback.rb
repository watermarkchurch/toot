require 'net/http'

module Toot
  class CallsEventCallback
    include Sidekiq::Worker

    def perform(callback_url, event_data)
      uri = URI(callback_url)

      logger.info { "Event ID: #{event_data["id"]}" }
      logger.info { "URL: #{callback_url}" }
      logger.debug { "Payload: #{event_data.inspect}" }

      response = Toot.config.http_connection.post do |request|
        request.url uri
        request.body = event_data.to_json
        request.headers["Content-Type"] = "application/json"
      end

      logger.debug { "Response from callback service: #{response.inspect}" }

      if response.success?
        if response.headers["X-Toot-Unsubscribe"]
          logger.info { "Service requested unsubscribe via X-Toot-Unsubscribe header. Unsubscribing." }
          Toot.redis do |r|
            r.srem event_data["channel"], callback_url
          end
        end
      else
        logger.error { "Error response: #{response.inspect}" }
        raise CallbackFailure, "Response code: #{response.status}"
      end
    end
  end
end
