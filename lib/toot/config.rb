module Toot
  CONFIG_ATTRS = %i[
    channel_prefix
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

  end
end
