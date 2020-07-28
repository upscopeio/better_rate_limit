require 'action_controller'

require 'rate_limit/configurable'

module ActionController
  autoload :RateLimit, 'action_controller/rate_limit'
end

module RateLimit
  include Configurable
end

ActiveSupport.on_load(:action_controller) do
  include ActionController::RateLimit
end
