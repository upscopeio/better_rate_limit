require 'action_controller'
require 'better_rate_limit/configuration'

module BetterRateLimit
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def reset_configuration
      @configuration = Configuration.new
    end
  end
end

module ActionController
  autoload :BetterRateLimit, 'action_controller/better_rate_limit'
end

ActiveSupport.on_load(:action_controller) do
  include ActionController::BetterRateLimit
end
