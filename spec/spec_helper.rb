ENV["RAILS_ENV"] = "test"
require "rails"
require "simple_auth"
require File.dirname(__FILE__) + "/support/config/boot"
require "rspec/rails"

# Load database schema
load File.dirname(__FILE__) + "/schema.rb"

# Restore default configuration
RSpec.configure do |config|
  config.before :each do
    load File.dirname(__FILE__) + "/../lib/simple_auth/config.rb"
    SimpleAuth::Config.model = :user
  end
end
