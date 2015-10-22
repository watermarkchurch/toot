require 'spec_helper'

RSpec.describe Toot::HandlerService do
  let(:env) {
    {
      "REQUEST_METHOD" => "POST",
      "rack.input" => StringIO.new('{"channel":"test.channel","payload":123}'),
    }
  }

  context "with an event channel with a subscription" do
    let(:handler) { spy(:handler) }
    before do
      Toot.config.source :test, subscription_url: "", channel_prefix: "test."
      Toot.config.subscribe :test, 'channel', handler
    end

    it "enqueues the CallsHandlers job for the given event_data" do
      expect(Toot::CallsHandlers).to receive(:perform_async).with({ "channel" => "test.channel", "payload" => 123 })
      response = Rack::MockResponse.new(*described_class.call(env))
      expect(response.status).to eq(200)
    end

    it "does not include the X-Toot-Unsubscribe header" do
      response = Rack::MockResponse.new(*described_class.call(env))
      expect(response.headers.keys).to_not include("X-Toot-Unsubscribe")
    end
  end

  context "with an event channel with no subscription" do
    it "does not call the CallsHandlers job" do
      expect(Toot::CallsHandlers).to_not receive(:perform_async)
      response = Rack::MockResponse.new(*described_class.call(env))
      expect(response.status).to eq(200)
    end

    it "includes the X-Toot-Unsubscribe header" do
      response = Rack::MockResponse.new(*described_class.call(env))
      expect(response.status).to eq(200)
      expect(response.headers.keys).to include("X-Toot-Unsubscribe")
    end
  end

end
