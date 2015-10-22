require 'spec_helper'

RSpec.describe Toot::Event do

  describe "#initialize with no args" do
    it "sets timestamp to now" do
      obj = described_class.new
      expect(obj.timestamp).to be_within(1).of(Time.now)
    end

    it "sets payload to empty object" do
      obj = described_class.new
      expect(obj.payload).to eq({})
    end

    it "generates a unique id" do
      obj = described_class.new
      expect(obj.id).to match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
      expect(described_class.new.id).to_not eq(described_class.new.id)
    end
  end

  describe "#initialize with hash" do
    it "sets timestamp to :timestamp" do
      time = Time.new(2020, 10, 20, 00, 00, 00)
      obj = described_class.new(timestamp: time)
      expect(obj.timestamp).to eq(time)
    end

    it "sets payload to :payload" do
      obj = described_class.new(payload: { data: 1 })
      expect(obj.payload).to eq({ data: 1 })
    end

    it "sets channel to :channel" do
      obj = described_class.new(channel: "foo")
      expect(obj.channel).to eq("foo")
    end

    it "sets id to :id" do
      obj = described_class.new(id: "foo")
      expect(obj.id).to eq("foo")
    end

    it "allows string keys" do
      obj = described_class.new("id" => "foo", :payload => { "data" => 1 })
      expect(obj.id).to eq("foo")
      expect(obj.payload).to eq({ "data" => 1 })
    end
  end

  describe "#publish" do
    subject(:event) { described_class.new }

    it "calls PublishesEvent with encoded self" do
      expect(Toot::PublishesEvent).to receive(:perform_async).with(event.to_h)
      event.publish
    end

    it "returns self" do
      expect(event.publish).to eq(event)
    end
  end

  describe "#to_h" do
    subject(:event) { described_class.new }

    it "includes :id in hash" do
      expect(event.to_h[:id]).to eq(event.id)
    end

    it "includes :timestamp in hash" do
      expect(event.to_h[:timestamp]).to eq(event.timestamp)
    end

    it "includes :payload in hash" do
      expect(event.to_h[:payload]).to eq(event.payload)
    end

    it "includes :channel in hash" do
      event.channel = "foo"
      expect(event.to_h[:channel]).to eq(event.channel)
    end

  end

  describe "==" do
    it "returns true if ids are the same and false otherwise" do
      obj1 = described_class.new
      obj2 = described_class.new(id: obj1.id)
      expect(obj1).to eq(obj2)
      expect(obj1).to_not eq(described_class.new)
    end
  end

  describe "[]" do
    it "delegate to payload" do
      event = described_class.new(payload: { test: 123 })
      expect(event[:test]).to eq(123)
    end
  end
end
