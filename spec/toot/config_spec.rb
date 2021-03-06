# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Toot::Config do
  subject(:config) { described_class.new }

  describe 'channel_prefix attr' do
    it 'allows basic getting and setting' do
      config.channel_prefix = 'com.example.test'
      expect(config.channel_prefix).to eq('com.example.test')
    end
  end

  describe '#source' do
    it 'requires a source_name, subscription_url, and channel_prefix' do
      expect { config.source }.to raise_error(ArgumentError)
      expect { config.source :source_name }.to raise_error(ArgumentError)
      expect { config.source :source_name, subscription_url: '' }.to raise_error(ArgumentError)
      config.source :source_name, subscription_url: '', channel_prefix: ''
    end

    it 'returns a Source object' do
      obj = config.source :name, subscription_url: 'https://example.com', channel_prefix: 'test'
      expect(obj).to be_a(Toot::Source)
      expect(obj.name).to eq(:name)
      expect(obj.subscription_url).to eq('https://example.com')
      expect(obj.channel_prefix).to eq('test')
    end

    it 'stores new Source object in @sources' do
      obj1 = config.source :name1, subscription_url: 'https://example.com', channel_prefix: 'test'
      obj2 = config.source :name2, subscription_url: 'https://example.com', channel_prefix: 'test'
      expect(config.sources).to eq([obj1, obj2])
    end
  end

  describe '#subscribe' do
    let!(:source) { config.source :source, subscription_url: '', channel_prefix: 'prefix.' }

    it 'requires a source_name, a channel_suffix, and a handler' do
      expect { config.subscribe }.to raise_error(ArgumentError)
      expect { config.subscribe :source }.to raise_error(ArgumentError)
      expect { config.subscribe :source, 'updated' }.to raise_error(ArgumentError)
      config.subscribe :source, 'updated', :handler
    end

    it 'returns the new Subscription' do
      obj = config.subscribe :source, 'suffix', :handler
      expect(obj).to be_a(Toot::Subscription)
      expect(obj.source).to eq(source)
      expect(obj.channel).to eq('prefix.suffix')
      expect(obj.handler).to eq(:handler)
    end

    it 'adds new Subscription to @subscriptions' do
      obj1 = config.subscribe :source, 'test', :handler
      obj2 = config.subscribe :source, 'test', :handler
      expect(config.subscriptions).to eq([obj1, obj2])
    end

    it "raises a ConfigError if the source doesn't exist" do
      expect { config.subscribe :no_source, 'foo', :handler }
        .to raise_error(Toot::ConfigError).with_message('You cannot subscribe to an undefined source: no_source')
    end
  end

  describe '#redis_connection' do
    it 'allows basic getting and setting' do
      config.redis_connection = -> { :redis }
      expect(config.redis_connection.call).to eq(:redis)
    end

    it 'defaults to Sidekiq.redis method' do
      expect(config.redis_connection).to eq(Sidekiq.method(:redis))
    end
  end

  describe '#http_connection' do
    it 'allows basic getting and setting' do
      config.http_connection = :http
      expect(config.http_connection).to eq(:http)
    end

    it 'defaults to a new Faraday::Connection' do
      expect(config.http_connection).to be_a(Faraday::Connection)
    end

    it 'caches the connection' do
      expect(config.http_connection.object_id)
        .to eq(config.http_connection.object_id)
    end
  end

  describe '#callback_url' do
    it 'allows basic getting and setting' do
      config.callback_url = 'http://example.com/callback'
      expect(config.callback_url).to eq('http://example.com/callback')
    end
  end

  describe '#find_source_by_name' do
    it 'returns the source with the given name' do
      src1 = config.source :src1, subscription_url: '', channel_prefix: ''
      _src2 = config.source :src2, subscription_url: '', channel_prefix: ''
      expect(config.find_source_by_name(:src1)).to eq(src1)
      expect(config.find_source_by_name(:src3)).to eq(nil)
    end
  end

  describe '#subscriptions_for_channel' do
    before do
      config.source :test, subscription_url: '', channel_prefix: ''
    end

    it 'returns all subscriptions for specified channel' do
      s1 = config.subscribe :test, 'ch1', :handler
      s2 = config.subscribe :test, 'ch1', :handler
      _s3 = config.subscribe :test, 'ch2', :handler
      expect(config.subscriptions_for_channel('ch1')).to eq([s1, s2])
    end

    it 'returns an empty array if none match' do
      config.subscribe :test, 'ch2', :handler
      expect(config.subscriptions_for_channel('ch1')).to eq([])
    end
  end
end
