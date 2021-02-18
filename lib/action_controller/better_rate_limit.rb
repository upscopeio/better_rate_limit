require 'ostruct'
require 'better_rate_limit/throttle'
require 'better_rate_limit/limit'

module ActionController
  module BetterRateLimit
    extend ActiveSupport::Concern

    module ClassMethods
      def rate_limit(max, options)
        rate_limits << Limit.build(max, controller_path, {
                                        if: options[:if],
                                        unless: options[:unless],
                                        every: options[:every],
                                        name: options[:name] || controller_path,
                                        scope: options[:scope] || -> { real_ip },
                                        only: options[:only] || [],
                                        except: options[:except] || [],
                                        clear_if: options[:clear_if]
                                      })

        before_action :perform_rate_limiting
        after_action :clear_keys
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

      render file: 'public/429.html', status: :too_many_requests, layout: false
    end

    def clear_keys
      rate_limits = self.class.all_rate_limits.filter(&:clear_if_present?)
      return if rate_limits.empty?

      rate_limits.each do |rate_limit|
        scope = rate_limit.scope.is_a?(Proc) ? instance_exec(&rate_limit.scope) : send(rate_limit.scope)
        scope = scope.to_param if scope.respond_to?(:to_param)
        ::BetterRateLimit::Throttle.clear(rate_limit.key(scope))
      end
    end

    private

    def json?
      request.xhr? || request.format === :json
    end

    def real_ip
      request.headers['X-Forwarded-For'].try(:split, ',').try(:[], -2..-2).try(:first).try(:strip)
    end

    def under_rate_limit?(limit)
      if limit.has_if_condition?
        if_condition = limit._if.is_a?(Proc) ? instance_exec(&limit._if) : send(limit._if)
        return false unless if_condition
      end

      if limit.has_unless_condition?
        unless_condition = limit._unless.is_a?(Proc) ? instance_exec(&limit._unless) : send(limit._unless)
        return false if unless_condition
      end

      if limit.controller_path_is?(controller_path)
        return true if action_name.to_sym.in?([limit.except].flatten)
        return true if !limit.only.empty? && !action_name.to_sym.in?([limit.only].flatten)
      end

      scope = limit.scope.is_a?(Proc) ? instance_exec(&limit.scope) : send(limit.scope)
      scope = scope.to_param if scope.respond_to?(:to_param)

      ::BetterRateLimit::Throttle.allow? limit.key(scope), limit: limit.max, time_window: limit.every
    end
  end
end
