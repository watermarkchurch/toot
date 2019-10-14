# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Toot::RegistersSubscriptions do
  before do
    Toot.config.callback_url = 'http://me.com/cb'
    Toot.config.source :src1, subscription_url: 'http://src1.com/cb', channel_prefix: ''
    Toot.config.source :src2, subscription_url: 'http://src2.com/cb', channel_prefix: ''
    Toot.config.source :src3, subscription_url: 'http://src3.com/cb', channel_prefix: ''
    WebMock.enable!
  end

  it "does a POST to each subscribed channel to the source's subscribe_url" do
    stub_request(:post, 'http://src1.com/cb').and_return(status: 200)
    stub_request(:post, 'http://src2.com/cb').and_return(status: 200)
    Toot.config.subscribe :src1, 'ch1', spy(:handler1)
    Toot.config.subscribe :src2, 'ch2', spy(:handler2)

    described_class.call

    expect(WebMock).to have_requested(:post, 'http://src1.com/cb')
      .with { |req|
        json = JSON.parse(req.body)
        expect(json['channel']).to eq('ch1')
        expect(json['callback_url']).to eq('http://me.com/cb')
      }
    expect(WebMock).to have_requested(:post, 'http://src2.com/cb')
      .with { |req|
        json = JSON.parse(req.body)
        expect(json['channel']).to eq('ch2')
        expect(json['callback_url']).to eq('http://me.com/cb')
      }
  end

  it "doesn't make multiple requests for duplicated channel subscriptions" do
    stub_request(:post, 'http://src1.com/cb').and_return(status: 200)
    Toot.config.subscribe :src1, 'ch1', spy(:handler1)
    Toot.config.subscribe :src1, 'ch1', spy(:handler2)

    described_class.call

    expect(WebMock).to have_requested(:post, 'http://src1.com/cb').once
  end

  it 'raises RegisterSubscriptionFailure if response is not successful' do
    stub_request(:post, 'http://src1.com/cb').and_return(status: 400)
    Toot.config.subscribe :src1, 'ch1', spy(:handler1)

    expect { described_class.call }.to raise_error(Toot::RegisterSubscriptionFailure)
      .with_message(/400/)
  end

  it 'uses the configured http_connection in Toot.config' do
    conn = instance_spy(Faraday::Connection)
    allow(Toot.config).to receive(:http_connection).and_return(conn)
    Toot.config.subscribe :src1, 'ch1', spy(:handler1)
    expect(conn).to receive(:post).and_return(double(success?: true))
    described_class.call
  end
end
