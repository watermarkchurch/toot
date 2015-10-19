module Toot
  class Subscription

    attr_accessor :source, :channel, :handler

    def initialize(source:, channel:, handler:)
      @source = source
      @channel = channel
      @handler = handler
    end

  end
end
