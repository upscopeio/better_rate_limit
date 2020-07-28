require 'spec_helper'
require_relative '../lib/rate_limit/configurable'

class FakeClass
  include RateLimit::Configurable
end

module RateLimit
  RSpec.describe Configurable do
    before do
      FakeClass.configure do |config|
        config.app_name = 'Foo'
        config.notifier = {
          klass: FakeClass,
          channel: '#foo'
        }
      end
    end

    describe '.configure' do
      it 'sets the values of Configuration class' do
        expect(FakeClass.config.app_name).to eq 'Foo'
        expect(FakeClass.config.notifier[:klass]).to eq FakeClass
        expect(FakeClass.config.notifier[:channel]).to eq '#foo'
      end
    end

    describe '.config' do
      it 'returns an instance of Configuration class' do
        expect(FakeClass.config).to be_an_instance_of(RateLimit::Configurable::Configuration)
      end
    end
  end
end
