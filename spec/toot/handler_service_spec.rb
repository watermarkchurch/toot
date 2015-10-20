require 'spec_helper'

RSpec.describe Toot::HandlerService do
  let(:env) {
    {
      "REQUEST_METHOD" => "POST",
      "QUERY_STRING" => "channel_name=test.channel",
      "rack.input" => StringIO.new('{"payload":123}'),
    }
  }

  context "with an event channel with a subscription" do
    let(:handler) { spy(:handler) }
    before do
      Toot.config.source :test, subscription_url: "", channel_prefix: "test."
      Toot.config.subscribe :test, 'channel', handler
    end

    it "enqueues the handler with the provided payload" do
      response = Rack::MockResponse.new(*described_class.call(env))
      expect(handler).to have_received(:perform_async).with({ "payload" => 123 })
      expect(response.status).to eq(200)
    end

    it "enqueues multiple handlers when multiple have been defined" do
      other_handler = spy(:other_handler)
      Toot.config.subscribe :test, 'channel', other_handler
      described_class.call(env)
      expect(handler).to have_received(:perform_async)
      expect(other_handler).to have_received(:perform_async)
    end

    it "does not include the X-Toot-Unsubscribe header" do
      response = Rack::MockResponse.new(*described_class.call(env))
      expect(response.headers.keys).to_not include("X-Toot-Unsubscribe")
    end
  end

  context "with an event channel with no subscription" do
    it "does not call another channel" do
      handler = spy(:handler)
      Toot.config.source :test, subscription_url: "", channel_prefix: "test."
      Toot.config.subscribe :test, 'channel2', handler
      described_class.call(env)
      expect(handler).to_not have_received(:perform_async)
    end

    it "includes the X-Toot-Unsubscribe header" do
      response = Rack::MockResponse.new(*described_class.call(env))
      expect(response.status).to eq(200)
      expect(response.headers.keys).to include("X-Toot-Unsubscribe")
    end
  end

end
