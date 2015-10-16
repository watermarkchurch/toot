require 'spec_helper'

RSpec.describe Toot::Source do

  describe "#initialize" do
    subject(:source) { described_class.new(args) }
    let(:args) {
      {
        name: "test_name",
        subscription_url: "http://example.com",
        channel_prefix: "test",
      }
    }
    it "sets :name to @name" do
      expect(source.name).to eq("test_name")
    end

    it "sets :subscription_url to @subscription_url" do
      expect(source.subscription_url).to eq("http://example.com")
    end

    it "sets :channel_prefix to @channel_prefix" do
      expect(source.channel_prefix).to eq("test")
    end
  end

end
