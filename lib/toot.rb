require 'toot/version'

require 'sidekiq'

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

  class Error < StandardError; end
  class ConfigError < Error; end
  class CallbackFailure < Error; end
  class RegisterSubscriptionFailure < Error; end

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

  def self.redis(connection=config.redis_connection, &block)
    connection.call(&block)
  end

end

