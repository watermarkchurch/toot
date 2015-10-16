require 'spec_helper'

RSpec.describe Toot::Config do
  subject(:config) { described_class.new }

  describe "channel_prefix attr" do
    it "allows basic getting and setting" do
      config.channel_prefix = "com.example.test"
      expect(config.channel_prefix).to eq("com.example.test")
    end
  end

  describe "#source" do
    it "requires a source_name, subscription_url, and channel_prefix" do
      expect { config.source }.to raise_error(ArgumentError)
      expect { config.source :source_name }.to raise_error(ArgumentError)
      expect { config.source :source_name, subscription_url: "" }.to raise_error(ArgumentError)
      config.source :source_name, subscription_url: "", channel_prefix: ""
    end

    it "returns a Source object" do
      obj = config.source :name, subscription_url: "https://example.com", channel_prefix: "test"
      expect(obj).to be_a(Toot::Source)
      expect(obj.name).to eq(:name)
      expect(obj.subscription_url).to eq("https://example.com")
      expect(obj.channel_prefix).to eq("test")
    end

    it "stores new Source object in @sources" do
      obj1 = config.source :name1, subscription_url: "https://example.com", channel_prefix: "test"
      obj2 = config.source :name2, subscription_url: "https://example.com", channel_prefix: "test"
      expect(config.sources).to eq([obj1, obj2])
    end
  end

end
