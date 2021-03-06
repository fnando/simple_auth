# frozen_string_literal: true

require "./lib/simple_auth/version"

Gem::Specification.new do |s|
  s.name        = "simple_auth"
  s.version     = SimpleAuth::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/simple_auth"
  s.summary     = "A simple authentication system for Rails apps"
  s.description = s.summary
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`
                    .split("\n")
                    .map {|f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "globalid"
  s.add_dependency "rails"
  s.add_development_dependency "activerecord"
  s.add_development_dependency "bcrypt", "~> 3.1.7"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-utils"
  s.add_development_dependency "pry-meta"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-fnando"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "sqlite3"
end
