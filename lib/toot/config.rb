module Toot
  CONFIG_ATTRS = %i[
    channel_prefix
    redis_connection
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

    def sources
      @sources ||= []
    end

    def redis_connection
      self[:redis_connection] ||= Sidekiq.method(:redis)
    end

  end
end
