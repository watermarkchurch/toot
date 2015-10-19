module Toot
  class PublishesEvent
    include Sidekiq::Worker

    def perform(channel_name, payload)
      channel_callback_urls(channel_name)
        .map { |callback| CallsEventCallback.perform_async(callback, payload) }
    end

    private

    def channel_callback_urls(channel_name)
      Toot.redis do |r|
        r.smembers channel_name
      end
    end
  end
end
