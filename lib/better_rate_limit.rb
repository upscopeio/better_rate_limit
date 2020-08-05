require 'action_controller'

module ActionController
  autoload :BetterRateLimit, 'action_controller/better_rate_limit'
end

ActiveSupport.on_load(:action_controller) do
  include ActionController::BetterRateLimit
end
