require 'spec_helper'

RSpec.describe Toot::CallsEventCallback do

  before(:each) do
    WebMock.enable!
  end

  it "does a POST to the callback with the payload as a JSON encoded body" do
    stub_request(:post, "http://example.com/").and_return(status: 200)
    described_class.new.perform("http://example.com/", { payload: 123 })
    expect(WebMock).to have_requested(:post, "http://example.com/")
      .with(body: '{"payload":123}')
      .with(headers: { "Content-Type" => "application/json" })
  end

  it "raises a CallbackFailure exception if non-200 response" do
    stub_request(:post, "http://example.com/").and_return(status: 301)
    expect { described_class.new.perform("http://example.com/", {}) }
      .to raise_error(Toot::CallbackFailure).with_message(/301/)
  end

  it "Removes this callback from the channel's set if response header contains X-Toot-Unsubscribe"
end

