require "rspec/core/rake_task"
require File.dirname(__FILE__) + "/lib/simple_auth/version"

RSpec::Core::RakeTask.new

desc "Default: run specs."
task :default => :spec

begin
  require "jeweler"

  JEWEL = Jeweler::Tasks.new do |gem|
    gem.name = "simple_auth"
    gem.version = SimpleAuth::Version::STRING
    gem.summary = "A simple authentication system for Rails apps"
    gem.description = "When Authlogic & Devise are just too much."
    gem.authors = ["Nando Vieira"]
    gem.email = "fnando.vieira@gmail.com"
    gem.homepage = "http://github.com/fnando/simple_auth"
    gem.has_rdoc = true
    gem.add_dependency "rails", ">= 3.0.0"
  end

  Jeweler::GemcutterTasks.new
rescue LoadError => e
  puts "You don't Jeweler installed, so you won't be able to build gems."
end
