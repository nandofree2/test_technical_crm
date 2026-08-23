ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "devise"
require "devise/test/integration_helpers"
require_relative "support/factories"
require_relative "support/test_logger_formatter"

abort("The Rails environment is running in production mode!") if Rails.env.production?

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
