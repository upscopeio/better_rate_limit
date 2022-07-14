# frozen_string_literal: true

require 'redis'

class MissingRedisConfigError < StandardError
  def initialize
    super 'Redis client not set'
  end
end

module BetterRateLimit
  module RedisConnection
    def self.included(host)
      host.extend ClassMethods
    end

    module ClassMethods
      def redis_client
        @redis_client ||= BetterRateLimit.configuration.redis_client
      end
    end
  end
end
