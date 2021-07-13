# frozen_string_literal: true

require 'test_helper'

class ConfigurationTest < Minitest::Test
  def test_default_configuration
    assert_equal false, BetterRateLimit::Configuration.new.ignore
  end

  def test_configuration_ignore_option
    configuration = BetterRateLimit::Configuration.new
    configuration.ignore = true

    assert_equal true, configuration.ignore
  end
end
