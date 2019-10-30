
module Toot

  class Error < StandardError; end
  class ConfigError < Error; end
  class CallbackFailure < Error; end

  class RegisterSubscriptionFailure < Error;
    attr_reader :status

    def initialize(status_or_cause)
      if status_or_cause.is_a? Integer
        super("Response code: #{status_or_cause}")
        @status = status_or_cause
      else
        super(status_or_cause)
      end
    end
  end

end