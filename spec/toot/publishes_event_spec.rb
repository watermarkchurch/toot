require 'spec_helper'

RSpec.describe Toot::PublishesEvent do
  describe "#perform" do
    let(:connection) { instance_double(Redis) }

    before do
      allow(Toot).to receive(:redis) do |&blk|
        blk.call(connection)
      end
    end

    it "queries Toot.redis for set members enqueueing a CallsEventCallback for each item" do
      event_data = Toot::Event.new(channel: "channel").to_h
      expect(connection).to receive(:smembers).with("channel").and_return(["callback1", "callback2"])
      expect(Toot::CallsEventCallback).to receive(:perform_async).with("callback1", event_data)
      expect(Toot::CallsEventCallback).to receive(:perform_async).with("callback2", event_data)
      described_class.new.perform(event_data)
    end
  end
end
