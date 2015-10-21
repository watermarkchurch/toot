module Toot
  class RegistersSubscriptions

    def call
      subscriptions = Toot.config
        .subscriptions
        .each_with_object({}) { |s, hash| hash[[s.source, s.channel]] = s }
        .values

      subscriptions.each do |subscription|
        register(subscription)
      end
    end

    def self.call(*args)
      new.call(*args)
    end

    private def register(subscription)
      uri = URI(subscription.source.subscription_url)
      request = Net::HTTP::Post.new(uri)
      request.body = {
        callback_url: Toot.config.callback_url,
        channel_name: subscription.channel,
      }.to_json
      request.content_type = "application/json"

      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request request
      end

      case response
      when Net::HTTPSuccess
      else
        raise RegisterSubscriptionFailure, "Response code: #{response.code}"
      end
    end

  end
end
