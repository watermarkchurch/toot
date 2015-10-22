require 'spec_helper'

RSpec.describe Toot::CallsHandlers do
  let(:event) { Toot::Event.new(channel: "test.channel") }

  it "calls all registered event handlers for the given channel" do
    handler = spy(:handler)
    Toot.config.source :test, subscription_url: "", channel_prefix: ""
    Toot.config.subscribe :test, "test.channel", handler

    described_class.new.perform(event.to_h)

    expect(handler).to have_received(:call).with(event)
  end

  it "exits successfully when no event handlers defined for channel" do
    described_class.new.perform(event.to_h)
  end
end

