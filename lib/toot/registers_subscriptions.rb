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

      response = Toot.config.http_connection.post uri do |request|
        request.body = {
          callback_url: Toot.config.callback_url,
          channel: subscription.channel,
        }.to_json
        request.headers["Content-Type"] = "application/json"
      end

      unless response.success?
        raise RegisterSubscriptionFailure, "Response code: #{response.status}"
      end
    end

  end
end
