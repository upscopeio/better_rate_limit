require 'ostruct'
require 'better_rate_limit/throttle'

module ActionController
  module BetterRateLimit
    extend ActiveSupport::Concern

    module ClassMethods
      def rate_limit(max, every:, name: nil, scope: -> { real_ip }, only: [], except: [])
        rate_limits << OpenStruct.new({
                                        max: max,
                                        every: every,
                                        name: name || controller_path,
                                        scope: scope,
                                        only: only,
                                        except: except,
                                        controller_path: controller_path
                                      })

        before_action :perform_rate_limiting
      end

      def rate_limits
        @rate_limits ||= []
      end

      def all_rate_limits
        return rate_limits unless superclass.respond_to? :all_rate_limits

        rate_limits + superclass.all_rate_limits
      end
    end

    protected

    def perform_rate_limiting
      return if self.class.all_rate_limits.map { |r| under_rate_limit?(r) }.all? { |r| r === true }

      return render json: { error: 'Too many requests' }, status: :too_many_requests if json?

      send_file 'public/429.html', status: :too_many_requests
    end

    private

    def json?
      request.xhr? || request.format === :json
    end

    def real_ip
      request.headers['X-Forwarded-For'].try(:split, ',').try(:[], -2..-2).try(:first).try(:strip)
    end

    def under_rate_limit?(limit)
      if limit.controller_path == controller_path
        return true if action_name.to_sym.in?([limit.except].flatten)
        return true if !limit.only.empty? && !action_name.to_sym.in?([limit.only].flatten)
      end

      scope = limit.scope.is_a?(Proc) ? instance_exec(&limit.scope) : send(limit.scope)
      scope = scope.to_param if scope.respond_to?(:to_param)

      key = ['controller_throttle', limit.name, limit.max, limit.every, scope].join(':')

      ::BetterRateLimit::Throttle.allow? key, limit: limit.max, time_window: limit.every
    end
  end
end
