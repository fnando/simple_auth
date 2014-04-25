require "./lib/simple_auth/version"

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

  s.add_dependency "rails", ">= 3.1.0"
  s.add_development_dependency "sqlite3-ruby"
  s.add_development_dependency "rspec-rails", "3.0.0.beta2"
  s.add_development_dependency "bcrypt", "~> 3.1.7"
  s.add_development_dependency "pry-meta"
end
