require 'spec_helper'

RSpec.describe Toot::SubscriptionsService do
  let(:connection) { instance_spy(Redis) }
  let(:env) {
    {
      "REQUEST_METHOD" => "POST",
      "rack.input" => StringIO.new('{"callback_url":"http://example.com/callback","channel_name":"test.channel"}'),
    }
  }

  before do
    allow(Toot).to receive(:redis) do |&blk|
      blk.call(connection)
    end
  end

  it "adds the given callback_url to the channel's set in Redis" do
    response = Rack::MockResponse.new(*described_class.call(env))
    expect(connection).to have_received(:sadd).with("test.channel", "http://example.com/callback")
    expect(response.status).to eq(200)
  end

  it "does nothing and return 422 if channel_name isn't set" do
    env["rack.input"] = StringIO.new('{"callback_url":"http://example.com/callback"}')
    response = Rack::MockResponse.new(*described_class.call(env))
    expect(connection).to_not have_received(:sadd)
    expect(response.status).to eq(422)
  end

  it "does nothing and returns 422 if callback_url isn't set" do
    env["rack.input"] = StringIO.new('{"channel_name":"test.channel"}')
    response = Rack::MockResponse.new(*described_class.call(env))
    expect(connection).to_not have_received(:sadd)
    expect(response.status).to eq(422)
  end

  it "allows setting options through the query string" do
    env["rack.input"] = StringIO.new('')
    env["QUERY_STRING"] = "channel_name=test.channel&callback_url=http://example.com/callback"
    response = Rack::MockResponse.new(*described_class.call(env))
    expect(connection).to have_received(:sadd).with("test.channel", "http://example.com/callback")
    expect(response.status).to eq(200)
  end

end
