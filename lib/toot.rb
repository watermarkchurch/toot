require 'toot/version'

require 'toot/source'
require 'toot/config'

module Toot

  def self.config
    if block_given?
      yield config
    else
      @config ||= Config.new
    end
  end

end

