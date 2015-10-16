require 'spec_helper'

RSpec.describe Toot do
  it "has a version number" do
    expect(Toot::VERSION).not_to be nil
  end

  describe "#config" do
    it "returns a config instance" do
      expect(Toot.config).to be_a(Toot::Config)
    end

    it "passes a config instance to a block if provided" do
      config = :none
      Toot.config { |c| config = c }
      expect(config).to be_a(Toot::Config)
    end

    it "returns the same config instance each time" do
      expect(Toot.config).to eq(Toot.config)
    end
  end
end
