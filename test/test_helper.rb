$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "bundler/setup"
require "rack/test"
require "minitest/utils"
require "minitest/autorun"

require "./test/support/dummy/config/application"
require "./test/support/dummy/config/routes"

require "active_record"
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
require "./test/support/schema"

Dir["./test/support/**/*.rb"].each {|file| require file }
