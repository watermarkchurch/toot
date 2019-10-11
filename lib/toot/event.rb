require 'securerandom'

module Toot
  class Event

    attr_accessor :id, :timestamp, :payload, :channel

    DEFAULTS = -> {
      {
        id: SecureRandom.uuid,
        timestamp: Time.now,
        payload: {},
      }
    }

    def initialize(args={})
      args = DEFAULTS.().merge(_symbolize_keys(args))
      @id = args[:id]
      @timestamp = args[:timestamp]
      @payload = args[:payload]
      @channel = args[:channel]
    end

    def publish
      PublishesEvent.perform_async(to_h)
      self
    end

    def to_h
      {
        id: id,
        timestamp: timestamp,
        payload: payload,
        channel: channel,
      }
    end

    def ==(other)
      self.id == other.id
    end

    def [](key)
      payload[key]
    end

    private

    def _symbolize_keys(h)
      h.inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end
  end
end
