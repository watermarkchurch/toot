module Toot
  CONFIG_ATTRS = %i[
    channel_prefix
    http_connection
    redis_connection
    callback_url
    request_filter
  ]

  class Config < Struct.new(*CONFIG_ATTRS)

    def source(name, subscription_url:, channel_prefix:)
      Source.new(
        name: name,
        subscription_url: subscription_url,
        channel_prefix: channel_prefix
      ).tap do |source|
        sources << source
      end
    end

    def subscribe(source_name, channel_suffix, handler)
      source = find_source_by_name(source_name) or
        fail(ConfigError, "You cannot subscribe to an undefined source: #{source_name}")
      Subscription.new(
        source: source,
        channel: [source.channel_prefix, channel_suffix].join,
        handler: handler
      ).tap do |subscription|
        subscriptions << subscription
      end
    end

    def sources
      @sources ||= []
    end

    def subscriptions
      @subscriptions ||= []
    end

    def find_source_by_name(name)
      sources.find { |source| source.name == name }
    end

    def subscriptions_for_channel(channel)
      subscriptions.select { |s| s.channel == channel }
    end

    def http_connection
      self[:http_connection] ||= Faraday::Connection.new
    end

    def redis_connection
      self[:redis_connection] ||= Sidekiq.method(:redis)
    end

    def request_filter
      self[:request_filter] ||= -> (request) { request }
    end

  end
end
