# frozen_string_literal: true

require 'test_helper'

class ThrottleTest < Minitest::Test
  def setup
    @subject = BetterRateLimit::Throttle
    @subject.instance_variable_set(:@redis_client, MockRedis.new)
    @redis = @subject.redis_client
  end

  def test_adds_current_timestamp_to_redis_list
    key = 'foo'
    timestamps_list = -> { @redis.lrange key, 0, -1 }

    @subject.throttle(key, limit: 2, time_window: 1.hour)

    refute_nil timestamps_list.call
  end

  def test_sets_expire_to_1_hour
    time_window = 1.hour
    @subject.throttle('foo', limit: 2, time_window: time_window)

    assert_equal time_window.to_i, @subject.redis_client.ttl('foo')
  end
end
