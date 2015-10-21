module Toot
  class PublishesEvent
    include Sidekiq::Worker

    def perform(event_data)
      event = Event.new(event_data)
      channel_callback_urls(event.channel)
        .map { |callback| CallsEventCallback.perform_async(callback, event_data) }
    end

    private

    def channel_callback_urls(channel)
      Toot.redis do |r|
        r.smembers channel
      end
    end
  end
end
