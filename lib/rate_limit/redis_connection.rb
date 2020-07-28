# frozen_string_literal: true

require 'redis'

module RateLimit
  module RedisConnection
    def self.included(host)
      host.extend ClassMethods
    end

    module ClassMethods
      def redis_client
        @redis_client ||= RateLimit.config.redis_client
      end
    end
  end
end
