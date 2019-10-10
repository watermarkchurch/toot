# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Toot do
  it 'has a version number' do
    expect(Toot::VERSION).not_to be nil
  end

  describe '#config' do
    it 'returns a config instance' do
      expect(Toot.config).to be_a(Toot::Config)
    end

    it 'passes a config instance to a block if provided' do
      config = :none
      Toot.config { |c| config = c }
      expect(config).to be_a(Toot::Config)
    end

    it 'returns the same config instance each time' do
      expect(Toot.config.object_id).to eq(Toot.config.object_id)
    end
  end

  describe '#reset_config' do
    it 'sets config to a new object' do
      initial = Toot.config
      Toot.reset_config
      expect(Toot.config.object_id).to_not eq(initial.object_id)
    end
  end

  describe '#publish' do
    it 'returns an event' do
      event = Toot.publish('channel', { payload: true })
      expect(event).to be_a(Toot::Event)
    end

    it 'calls Event.new with args' do
      event = Toot.publish('channel', {})
      expect(event.channel).to eq('channel')
      expect(event.payload).to eq({})
    end

    it 'adds prefix option to channel name if present' do
      event = Toot.publish('channel', {}, prefix: 'prefix.')
      expect(event.channel).to eq('prefix.channel')
    end

    it "uses config's channel_prefix if present and no prefix passed" do
      Toot.config.channel_prefix = 'prefix.'
      event = Toot.publish('channel', {})
      expect(event.channel).to eq('prefix.channel')
    end

    it 'calls publish on the event' do
      event_spy = instance_spy(Toot::Event)
      expect(Toot::Event).to receive(:new).and_return(event_spy)
      Toot.publish('channel', {})
      expect(event_spy).to have_received(:publish)
    end
  end

  describe '#subscribe' do
    it 'delegates to config.subscribe' do
      expect(Toot.config).to receive(:subscribe).with(:source_name, :channel_suffix, :handler)
      Toot.subscribe(:source_name, :channel_suffix, :handler)
    end
  end

  describe '#redis' do
    it 'calls the passed connection with the passed block' do
      called = false
      connection = method(:test_connection)

      Toot.redis(connection) do |val|
        expect(val).to eq(:foo)
        called = true
      end

      expect(called).to eq(true)
    end

    it 'defaults passed connection to the configured connection' do
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
