require 'spec_helper'

RSpec.describe Toot do
  it "has a version number" do
    expect(Toot::VERSION).not_to be nil
  end

  describe "#config" do
    it "returns a config instance" do
      expect(Toot.config).to be_a(Toot::Config)
    end

    it "passes a config instance to a block if provided" do
      config = :none
      Toot.config { |c| config = c }
      expect(config).to be_a(Toot::Config)
    end

    it "returns the same config instance each time" do
      expect(Toot.config.object_id).to eq(Toot.config.object_id)
    end
  end

  describe "#reset_config" do
    it "sets config to a new object" do
      initial = Toot.config
      Toot.reset_config
      expect(Toot.config.object_id).to_not eq(initial.object_id)
    end
  end

  describe "#publish" do
    it "accepts a channel_name and a payload" do
      Toot.publish("channel", { payload: true })
    end

    it "calls PublishesEvent.perform_async with args" do
      expect(Toot::PublishesEvent).to receive(:perform_async).with("channel", {})
      Toot.publish("channel", {})
    end

    it "adds prefix option to channel name if present" do
      expect(Toot::PublishesEvent).to receive(:perform_async).with("prefix.channel", {})
      Toot.publish("channel", {}, prefix: "prefix.")
    end

    it "uses config's channel_prefix if present and no prefix passed" do
      previous_value = Toot.config.channel_prefix
      expect(Toot::PublishesEvent).to receive(:perform_async).with("prefix.channel", {})
      Toot.config.channel_prefix = "prefix."
      Toot.publish("channel", {})
      Toot.config.channel_prefix = previous_value
    end
  end

  describe "#redis" do
    it "calls the passed connection with the passed block" do
      called = false
      connection = method(:test_connection)

      Toot.redis(connection) do |val|
        expect(val).to eq(:foo)
        called = true
      end

      expect(called).to eq(true)
    end

    it "defaults passed connection to the configured connection" do
      Toot.config.redis_connection = method(:test_connection)

      Toot.redis do |val|
        expect(val).to eq(:foo)
      end
    end

    def test_connection
      yield :foo
    end

  end
end
