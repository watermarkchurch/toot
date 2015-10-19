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
      expect(connection).to receive(:smembers).with("channel").and_return(["callback1", "callback2"])
      expect(Toot::CallsEventCallback).to receive(:perform_async).with("callback1", {})
      expect(Toot::CallsEventCallback).to receive(:perform_async).with("callback2", {})
      described_class.new.perform("channel", {})
    end
  end
end