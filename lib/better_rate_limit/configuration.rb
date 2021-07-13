# frozen_string_literal: true

module BetterRateLimit
  class Configuration
    attr_accessor :ignore

    def initialize
      @ignore = false
    end
  end
end
