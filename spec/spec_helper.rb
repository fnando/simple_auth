ENV["RAILS_ENV"] = "test"
require "bundler/setup"
Bundler.require

I18n.load_path += Dir[File.expand_path("../../locales/*.yml", __FILE__)]

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
  end
end
