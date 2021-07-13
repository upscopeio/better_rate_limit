# frozen_string_literal: true

require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/time/calculations'
require 'better_rate_limit/redis_connection'

module BetterRateLimit
  module Throttle
    include RedisConnection

    class << self
      def throttle(key, limit:, time_window:)
        return true if BetterRateLimit.configuration.ignore

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

          return false unless first

          passing = first.to_time(:utc) < time_window.ago

          unless passing
            notify(key) unless redis_client.exists('failing-rate-limits:' + key)
            redis_client.setex('failing-rate-limits:' + key, time_window.to_i, '1')
          end

          passing
        end
      end

      def clear(key)
        redis_client.del(key)
        redis_client.del("failing-rate-limits:#{key}")
      end

      alias allow? throttle

      def notify(key)
        ActiveSupport::Notifications.instrument 'rate_limit.notify', { rate_limit_key: key }
      end
    end
  end
end
