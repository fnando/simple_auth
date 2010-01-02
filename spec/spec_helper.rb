# Load application RSpec helper
begin
  require File.dirname(__FILE__) + "/../../../../spec/spec_helper"
rescue LoadError
  puts "Your application hasn't been bootstraped with RSpec.\nI'll do it on my own!\n\n"
  system "cd '#{File.dirname(__FILE__) + "/../../../../"}' && script/generate rspec"
  puts "\n\nRun `rake spec` again."
  exit
end

# Establish connection with in memory SQLite 3 database
ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

# Load database schema
load File.dirname(__FILE__) + "/schema.rb"

# Create an alias for lambda
alias :doing :lambda

# Load resources
require File.dirname(__FILE__) + "/resources/user"
require File.dirname(__FILE__) + "/resources/controllers"

# Restore default configuration
Spec::Runner.configure do |config|
  config.before :each do
    load File.dirname(__FILE__) + "/../lib/simple_auth/config.rb"
    SimpleAuth::Config.model = :user
  end
end
