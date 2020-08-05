# frozen_string_literal: true

require 'bundler/setup'
require 'minitest/autorun'
require 'mocha/minitest'

require 'active_support'

$:.unshift File.expand_path("../../lib", __FILE__)
require "better_rate_limit"

BetterRateLimit::Routes = ActionDispatch::Routing::RouteSet.new
BetterRateLimit::Routes.draw do
  resources :users
end

class ActiveSupport::TestCase
  self.test_order = :random

  setup do
    @routes = BetterRateLimit::Routes
  end
end


class ApplicationController < ActionController::Base
  include BetterRateLimit::Routes.url_helpers

  self.view_paths = File.join(File.dirname(__FILE__), "public")
  respond_to? :html, :json
end
