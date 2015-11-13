module Toot
  class CallsHandlers
    include Sidekiq::Worker

    def perform(event_data)
      event = Event.new(event_data)

      logger.info { "Event ID: #{event_data["id"]}" }
      logger.debug { "Payload: #{event_data.inspect}" }

      Toot.config
        .subscriptions_for_channel(event.channel)
        .each { |s| s.handler.call(event) }
    end

  end
end
