# frozen_string_literal: true

require 'test_helper'

class TeamsController < ApplicationController
  rate_limit 2, every: 1.minute, only: :index, clear_if: -> { condition }

  def index
    render plain: 'Hello World'
  end

  def condition
    true
  end
end

class TeamsControllerTest < ActionController::TestCase
  def setup
    ::BetterRateLimit::Throttle.instance_variable_set(:@redis_client, MockRedis.new)
  end

  tests TeamsController

  def test_clear_if
    get :index, xhr: true

    assert_equal 200, @response.status
  end
end
