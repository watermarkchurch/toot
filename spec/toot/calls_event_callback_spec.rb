require 'spec_helper'

RSpec.describe Toot::CallsEventCallback do
  let(:connection) { instance_double(Redis) }

  before do
    allow(Toot).to receive(:redis) do |&blk|
      blk.call(connection)
    end
  end

  before(:each) do
    WebMock.enable!
  end

  it "does a POST to the callback with the event_data as a JSON encoded body" do
    stub_request(:post, "http://example.com/").and_return(status: 200)
    described_class.new.perform("http://example.com/", { data: 123 })
    expect(WebMock).to have_requested(:post, "http://example.com/")
      .with(body: '{"data":123}')
      .with(headers: { "Content-Type" => "application/json" })
  end

  it "raises a CallbackFailure exception if non-200 response" do
    stub_request(:post, "http://example.com/").and_return(status: 301)
    expect { described_class.new.perform("http://example.com/", {}) }
      .to raise_error(Toot::CallbackFailure).with_message(/301/)
  end

  it "Removes this callback from the channel's set if response header contains X-Toot-Unsubscribe" do
    stub_request(:post, "http://example.com/")
      .and_return(status: 200, headers: { "X-Toot-Unsubscribe" => "True" })
    expect(connection).to receive(:srem).with("ch1", "http://example.com/")
    described_class.new.perform("http://example.com/", "channel" => "ch1")
  end

  it "passes the request through the configured `Toot.config.request_filter`" do
    stub_request(:post, "http://example.com/").and_return(status: 200)
    Toot.config.request_filter = -> (request) {
      request["X-Test-Header"] = "Here I Am"
      request
    }

    described_class.new.perform("http://example.com/", {})

    expect(WebMock).to have_requested(:post, "http://example.com/")
      .with(headers: { "X-Test-Header" => "Here I Am" })
  end
end

