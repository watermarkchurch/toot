module Toot
  class CallsHandlers
    include Sidekiq::Worker

    def perform(event_data)
      event = Event.new(event_data)
      Toot.config
        .subscriptions_for_channel(event.channel)
        .each { |s| s.handler.call(event) }
    end

  end
end
