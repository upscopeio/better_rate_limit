# frozen_string_literal: true

require 'redis'

module RateLimit
  module RedisConnection
    def self.included(host)
      host.extend ClassMethods
    end

    module ClassMethods
      def redis_client
        @redis_client ||= Redis.new url: ENV['REDIS_URL']
      end
    end
  end
end
