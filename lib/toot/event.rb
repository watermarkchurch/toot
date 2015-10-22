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
      args = DEFAULTS.().merge(args.symbolize_keys)
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
  end
end
