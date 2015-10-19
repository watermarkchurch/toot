require 'toot/version'

require 'sidekiq'

require 'toot/config'
require 'toot/publishes_event'
require 'toot/calls_event_callback'
require 'toot/source'
require 'toot/subscription'

module Toot

  class Error < StandardError; end
  class ConfigError < Error; end
  class CallbackFailure < Error; end

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

  def self.publish(channel_name, payload, prefix: config.channel_prefix)
    PublishesEvent.perform_async([prefix, channel_name].join, payload)
  end

  def self.redis(connection=config.redis_connection, &block)
    connection.call(&block)
  end

end

