require 'toot/version'

require 'sidekiq'

require 'toot/config'
require 'toot/publishes_event'
require 'toot/source'

module Toot

  def self.config
    if block_given?
      yield config
    else
      @config ||= Config.new
    end
  end

  def self.publish(channel_name, payload, prefix: config.channel_prefix)
    PublishesEvent.perform_async([prefix, channel_name].join, payload)
  end

end

