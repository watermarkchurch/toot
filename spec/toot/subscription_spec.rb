# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Toot::Subscription do
  describe '#initialize' do
    subject(:subscription) { described_class.new(args) }
    let(:args) {
      {
        source: :source,
        channel: 'foo.bar',
        handler: :handler
      }
    }

    it 'sets :source to @source' do
      expect(subscription.source).to eq(:source)
    end

    it 'sets :channel to @channel' do
      expect(subscription.channel).to eq('foo.bar')
    end

    it 'sets :handler to @handler' do
      expect(subscription.handler).to eq(:handler)
    end
  end
end
