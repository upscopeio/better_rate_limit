# frozen_string_literal: true

require 'test_helper'

class ConditionalIfController < ApplicationController
  rate_limit 2, if: -> { condition }, every: 1.minute, only: :index

  def index
    render plain: 'Hello World!'
  end

  def condition
    true
  end
end

class ConditionalUnlessController < ApplicationController
  rate_limit 2, unless: -> { condition }, every: 1.minute, only: :index

  def index
    render plain: 'Hello World!'
  end

  def condition
    true
  end
end

class ConditionalIfUsersControllerRateLimitTest < ActionController::TestCase
  def setup
    BetterRateLimit.configure do |config|
      config.redis_client = MockRedis.new
    end
  end

  def teardown
    BetterRateLimit.reset_configuration
  end

  tests ConditionalIfController

  def test_conditional_if_rate_limit_2_requests_1_minute_json
    3.times { get :index, xhr: true }

    parsed_body = JSON.parse(@response.body, symbolize_names: true)

    assert_equal 429, @response.status
    assert_equal 'Too many requests', parsed_body[:error]
  end

  def test_conditional_if_false_rate_limit
    @controller.class_eval do
      define_method(:condition) do
        false
      end
    end

    get :index

    assert_equal 200, @response.status
  end
end

class ConditionaUnlessUsersControllerRateLimitTest < ActionController::TestCase
  tests ConditionalUnlessController

  def test_conditional_unless_rate_limit_2_requests_1_minute_json
    get :index, xhr: true

    assert_equal 200, @response.status
  end

  def test_conditional_unless_false_rate_limit
    @controller.class_eval do
      define_method(:condition) do
        false
      end
    end

    get :index

    assert_equal 200, @response.status
  end
end
