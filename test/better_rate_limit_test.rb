# frozen_string_literal: true

require 'test_helper'

class BetterRateLimitTest < ActiveSupport::TestCase
  test 'version' do
    assert_not_equal nil, BetterRateLimit::VERSION
  end

  test 'configuration' do
    BetterRateLimit.configure do |config|
      config.ignore = true
    end

    assert_equal true, BetterRateLimit.configuration.ignore
  end

  test 'reset configuration' do
    BetterRateLimit.configure do |config|
      config.ignore = true
    end

    assert_equal true, BetterRateLimit.configuration.ignore

    BetterRateLimit.reset_configuration

    assert_equal false, BetterRateLimit.configuration.ignore
  end
end
