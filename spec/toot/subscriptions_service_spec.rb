# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Toot::SubscriptionsService do
  let(:connection) { instance_spy(Redis) }

  before do
    allow(Toot).to receive(:redis) do |&blk|
      blk.call(connection)
    end

    Toot.config.channel_prefix = 'wcc.toot.test.'
  end

  describe 'post' do
    let(:env) {
      {
        'REQUEST_METHOD' => 'POST',
        'rack.input' => StringIO.new('{"callback_url":"http://example.com/callback","channel":"test.channel"}')
      }
    }

    it "adds the given callback_url to the channel's set in Redis" do
      expect(connection).to receive(:sadd)
        .with('test.channel', 'http://example.com/callback')
        .and_return(true)

      # act
      response = Rack::MockResponse.new(*described_class.call(env))

      puts response.body
      expect(response.status).to eq(201)
    end

    it 'returns 204 if the callback_url already exists in redis' do
      expect(connection).to receive(:sadd)
        .with('test.channel', 'http://example.com/callback')
        .and_return(false)

      # act
      response = Rack::MockResponse.new(*described_class.call(env))

      puts response.body
      expect(response.status).to eq(204)
    end

    it "does nothing and return 422 if channel isn't set" do
      env['rack.input'] = StringIO.new('{"callback_url":"http://example.com/callback"}')

      # act
      response = Rack::MockResponse.new(*described_class.call(env))

      expect(connection).to_not have_received(:sadd)
      expect(response.status).to eq(422)
    end

    it "does nothing and returns 422 if callback_url isn't set" do
      env['rack.input'] = StringIO.new('{"channel":"test.channel"}')

      # act
      response = Rack::MockResponse.new(*described_class.call(env))

      expect(connection).to_not have_received(:sadd)
      expect(response.status).to eq(422)
    end
  end

  describe 'get json' do
    let(:env) {
      {
        'REQUEST_METHOD' => 'GET',
        'HTTP_ACCEPT' => 'application/json'
      }
    }

    it 'lists channels and subscriptions' do
      allow(connection).to receive(:keys)
        .and_return(['wcc.toot.test.x', 'wcc.toot.test.y'])

      allow(connection).to receive(:smembers)
        .with('wcc.toot.test.x')
        .and_return(['https://test.com/webhook'])
      allow(connection).to receive(:smembers)
        .with('wcc.toot.test.y')
        .and_return(['https://test2.com/webhook'])

      # act
      response = Rack::MockResponse.new(*described_class.call(env))

      expect(response.status).to eq(200)
      expect(response.content_type).to eq('application/json')
      body = JSON.parse(response.body)
      expect(body['channels']).to eq(['wcc.toot.test.x', 'wcc.toot.test.y'])
      expect(body['subscriptions']['wcc.toot.test.x'])
        .to eq(['https://test.com/webhook'])
    end
  end

  describe 'delete' do
    let(:env) {
      {
        'REQUEST_METHOD' => 'DELETE',
        'QUERY_STRING' => "channel=test.channel&callback_url=#{CGI.escape('http://example.com/callback')}",
        'rack.input' => StringIO.new('')
      }
    }

    it 'unsubscribes a webhook' do
      expect(connection).to receive(:srem)
        .with('test.channel', 'http://example.com/callback')
        .and_return(true)

      # act
      response = Rack::MockResponse.new(*described_class.call(env))

      expect(response.status).to eq(204)
    end

    it 'returns 404 when webhook does not exist in channel' do
      expect(connection).to receive(:srem)
        .with('test.channel', 'http://example.com/callback')
        .and_return(false)

      # act
      response = Rack::MockResponse.new(*described_class.call(env))

      expect(response.status).to eq(404)
    end
  end
end
