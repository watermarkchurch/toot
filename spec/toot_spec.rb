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
      expect(Toot.config).to eq(Toot.config)
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
end
