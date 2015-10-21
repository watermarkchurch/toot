require 'rack'

module Toot
  class HandlerService

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      event_data = JSON.parse(request.body.read)

      subscriptions = Toot.config.subscriptions.select { |s|
        s.channel == event_data["channel_name"] }

      subscriptions.each do |subscription|
        subscription.handler.perform_async(event_data)
      end

      response["X-Toot-Unsubscribe"] = "True" if subscriptions.size == 0

      response.finish
    end

    def self.call(env)
      new.call(env)
    end

  end
end
