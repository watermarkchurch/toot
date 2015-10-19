module Toot
  class CallsEventCallback
    include Sidekiq::Worker

    def perform(callback_url, payload)
    end
  end
end
