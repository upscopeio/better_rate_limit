require 'action_controller'

module ActionController
  autoload :RateLimit, 'action_controller/rate_limit'
end

ActiveSupport.on_load(:action_controller) do
  include ActionController::RateLimit
end
