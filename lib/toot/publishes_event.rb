module Toot
  class PublishesEvent
    include Sidekiq::Worker

    def perform(channel_name, payload)
    end
  end
end
