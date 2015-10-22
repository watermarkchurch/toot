require 'rack'

module Toot
  class HandlerService

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      event_data = JSON.parse(request.body.read)

      if Toot.config.subscriptions_for_channel(event_data["channel"]).any?
        CallsHandlers.perform_async(event_data)
      else
        response["X-Toot-Unsubscribe"] = "True"
      end

      response.finish
    end

    def self.call(env)
      new.call(env)
    end

  end
end
