# frozen_string_literal: true

require 'dotenv/load'

require 'simplecov'

Bundler.require(:test, :development)

# This needs require before app
require_relative 'support/simple_cov'
require_relative 'support'

require './initialize'

WebMock.disable_net_connect!(allow: %w[localhost 127.0.0.1 rabbitmq])

RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 1000

RSpec.configure do |config|
  config.include(RspecSequel::Matchers)
  config.include(SpecHelpers::Env)
  config.include(SpecHelpers::Connection)
  config.include(SpecHelpers::Fixtures)
  config.include(SpecHelpers::CloudFrontSigner)

  config.mock_with(:rspec) do |mocked_config|
    mocked_config.before_verifying_doubles do |reference|
      reference.target.define_attribute_methods if reference.target.respond_to?(:define_attribute_methods)
    end
  end
end
