ENV["RAILS_ENV"] = "test"
require "bundler/setup"
Bundler.require

I18n.load_path += Dir[File.expand_path("../../locales/*.yml", __FILE__)]
I18n.enforce_available_locales = false

require "rails"
require "simple_auth"
require File.dirname(__FILE__) + "/support/config/boot"
require "rspec/rails"

$rails_version = Rails::VERSION::STRING

# Load database schema
load File.dirname(__FILE__) + "/schema.rb"

# Restore default configuration
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.before :each do
    load File.dirname(__FILE__) + "/../lib/simple_auth/config.rb"
  end
end
