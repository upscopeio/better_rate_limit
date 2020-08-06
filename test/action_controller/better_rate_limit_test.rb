# frozen_string_literal: true

require "test_helper"

class UsersController < ApplicationController
  rate_limit 2, every: 1.minute, only: :index

  def index
    render plain: 'Hello World!'
  end
end

class UsersControllerRateLimitTest < ActionController::TestCase
  def setup
    BetterRateLimit::Throttle.instance_variable_set(:@redis_client, MockRedis.new)
  end

  tests UsersController

  def test_method_rate_limit_is_defined
    assert_equal true, UsersController.respond_to?(:rate_limit)
  end

  def test_rate_limit_2_requests_1_minute_json
    3.times { get :index, xhr: true }

    parsed_body = JSON.parse(@response.body, symbolize_names: true)

    assert_equal 429, @response.status
    assert_equal "Too many requests", parsed_body[:error]
  end

  def test_rate_limit_2_requests_1_minute
    3.times { get :index }

    assert_equal 429, @response.status
  end

  def test_rate_limit_after_1_minute
    3.times { get :index }

    assert_equal 429, @response.status

    Timecop.travel(2.minutes) do
      get :index

      assert_equal 200, @response.status
    end
  end
end
