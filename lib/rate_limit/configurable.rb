# frozen_string_literal: true

module RateLimit
  module Configurable
    def self.included(host)
      host.extend ClassMethods
    end

    module ClassMethods
      def config
        @config ||= Configuration.new
      end

      def configure
        yield config
      end
    end

    class Configuration
      attr_accessor :notify_method
    end
  end
end
