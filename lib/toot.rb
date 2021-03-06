require 'toot/version'

require 'faraday'
require 'sidekiq'

require 'toot/errors'
require 'toot/config'
require 'toot/event'
require 'toot/source'
require 'toot/subscription'

require 'toot/calls_event_callback'
require 'toot/calls_handlers'
require 'toot/handler_service'
require 'toot/publishes_event'
require 'toot/registers_subscriptions'
require 'toot/subscriptions_service'

module Toot

  def self.config
    if block_given?
      yield config
    else
      @config ||= Config.new
    end
  end

  def self.reset_config
    @config = Config.new
  end

  def self.publish(channel, payload, prefix: config.channel_prefix)
    Event.new(
      channel: [prefix, channel].join,
      payload: payload
    ).publish
  end

  def self.subscribe(*args)
    config.subscribe(*args)
  end

  def self.redis(connection=config.redis_connection, &block)
    connection.call(&block)
  end

end

require 'toot/rails' if defined?(Rails)
