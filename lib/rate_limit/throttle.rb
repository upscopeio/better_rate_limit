# frozen_string_literal: true

require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/time/calculations'
require 'rate_limit/redis_connection'
require 'rate_limit/configurable'

module RateLimit
  module Throttle
    include RedisConnection
    include Configurable

    class << self
      def throttle(key, limit:, time_window:)
        now = Time.now.utc
        timestamps_count = redis_client.llen key

        if timestamps_count < limit
          redis_client.multi do
            redis_client.rpush key, now
            redis_client.expire key, time_window.to_i
          end
          true
        else
          first = redis_client.lpop(key)
          redis_client.multi do
            redis_client.rpush key, now
            redis_client.expire key, time_window.to_i
          end

          passing = first.to_time(:utc) < time_window.ago

          unless passing
            notify(key) unless redis_client.exists('failing-rate-limits:' + key)
            redis_client.setex('failing-rate-limits:' + key, time_window.to_i, '1')
          end

          passing
        end
      end

      alias allow? throttle

      def notify(key)
        self.class.config.notify_method.call(key)
      end
    end
  end
end
