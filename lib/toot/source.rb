module Toot
  class Source

    attr_accessor :name, :subscription_url, :channel_prefix

    def initialize(name:, subscription_url:, channel_prefix:)
      @name = name
      @subscription_url = subscription_url
      @channel_prefix = channel_prefix
    end

  end
end
