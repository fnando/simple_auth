# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_auth/version"

Gem::Specification.new do |s|
  s.name        = "simple_auth"
  s.version     = SimpleAuth::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/simple_auth"
  s.summary     = "A simple authentication system for Rails apps"
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", ">= 3.0.0"
  s.add_development_dependency "sqlite3-ruby"
  s.add_development_dependency "rspec-rails", "~> 2.5.0"
  s.add_development_dependency "mongo_mapper", "~> 0.9.1"
  s.add_development_dependency "bson_ext"
  s.add_development_dependency "ruby-debug19"
end
