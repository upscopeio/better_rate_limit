# frozen_string_literal: true

module BetterRateLimit
  class Configuration
    attr_accessor :ignore, :redis_client, :proxies_to_trust

    def initialize
      @ignore = false
    end
  end
end
