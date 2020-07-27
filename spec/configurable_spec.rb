require 'spec_helper'
require_relative '../lib/rate_limit/configurable'

class FakeClass
  include RateLimit::Configurable
end

module RateLimit
  RSpec.describe Configurable do
    before do
      FakeClass.configure do |config|
        config.notify_method = -> { 2 + 2 }
      end
    end

    describe '.configure' do
      it 'sets the values of Configuration class' do
        expect(FakeClass.config.notify_method).not_to be_nil
      end
    end

    describe '.config' do
      it 'returns an instance of Configuration class' do
        expect(FakeClass.config).to be_an_instance_of(RateLimit::Configurable::Configuration)
      end
    end
  end
end
