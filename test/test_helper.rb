# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require "bundler/setup"
require "rack/test"
require "minitest/utils"
require "minitest/autorun"

require "./test/support/dummy/config/application"
require "./test/support/dummy/config/routes"
require "./test/support/dummy/app/controllers/application_controller"

require "active_record"
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
require "./test/support/schema"

Dir["./test/support/**/*.rb"].sort.each {|file| require file }
