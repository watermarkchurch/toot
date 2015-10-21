require 'rack'

module Toot
  class HandlerService

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      payload = JSON.parse(request.body.read)

      subscriptions = Toot.config.subscriptions.select { |s|
        s.channel == request["channel_name"] }

      subscriptions.each do |subscription|
        subscription.handler.perform_async(payload)
      end

      response["X-Toot-Unsubscribe"] = "True" if subscriptions.size == 0

      response.finish
    end

    def self.call(env)
      new.call(env)
    end

  end
end