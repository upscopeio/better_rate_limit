# frozen_string_literal: true

require 'test_helper'

module FakeModule
  include BetterRateLimit::RedisConnection
end

class RedisConnectionTest < Minitest::Test
  def setup
    @subject = FakeModule
    BetterRateLimit.configure do |config|
      config.redis_client = MockRedis.new
    end
  end

  def teardown
    BetterRateLimit.reset_configuration
  end

  def test_class_should_have_redis_connection
    assert_equal true, @subject.respond_to?(:redis_client)
  end

  def test_redis_client
    assert_instance_of MockRedis, @subject.redis_client
  end
end
