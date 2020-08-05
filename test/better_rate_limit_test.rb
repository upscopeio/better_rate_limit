# frozen_string_literal: true

require 'test_helper'

class BetterRateLimitTest < ActiveSupport::TestCase
  test 'version' do
    assert_not_equal nil, BetterRateLimit::VERSION
  end
end
