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
      # act
      response = Rack::MockResponse.new(*described_class.call(env))

      expect(connection).to have_received(:sadd).with('test.channel', 'http://example.com/callback')
      expect(response.status).to eq(200)
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
end
