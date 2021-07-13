# frozen_string_literal: true

require 'test_helper'

class ThrottleTest < Minitest::Test
  def setup
    @subject = BetterRateLimit::Throttle
    @subject.instance_variable_set(:@redis_client, MockRedis.new)
    @redis = @subject.redis_client
  end

  def add_keys_to_redis
    Timecop.freeze(Time.local(2020, 1, 1, 9, 0, 0))
    5.times do |i|
      @redis.rpush 'foo-throttle', Time.now.utc + i.minutes
    end
    Timecop.return
  end

  def test_do_not_throttle_if_ignore_is_set
    BetterRateLimit.configure do |config|
      config.ignore = true
    end

    assert_equal true, @subject.throttle('foo', limit: 2, time_window: 1.hour)

    BetterRateLimit.reset_configuration
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

  def test_when_passes_the_limit_within_time_window
    add_keys_to_redis

    timestamps_list = @redis.lrange 'foo-throttle', 0, -1
    fetch_timestamps_list = -> { @redis.lrange 'foo', 0, -1 }
    first = timestamps_list.first

    Timecop.freeze(first.to_time(:utc) + 2.hours)

    @subject.throttle('foo-throttle', limit: 5, time_window: 6.hours)

    refute_includes fetch_timestamps_list.call, first
  end

  def test_when_passes_the_limit_time_window_has_passed
    add_keys_to_redis

    timestamps_list = @redis.lrange 'foo-throttle', 0, -1
    first = timestamps_list.first

    Timecop.travel(first.to_time(:utc) + 7.hours)
    assert_equal true, @subject.throttle('foo-throttle', limit: 5, time_window: 6.hours)
  end
end
