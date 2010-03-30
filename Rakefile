require 'rake'
require 'spec/rake/spectask'

require 'jeweler'
require File.dirname(__FILE__) + '/lib/simple_auth/version'


desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format specdoc --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

JEWEL = Jeweler::Tasks.new do |gem|
  gem.name = "simple_auth"
  gem.version = SimpleAuth::Version::STRING
  gem.summary = "A simple authentication system for Rails apps"
  gem.description = <<-TXT
When Authlogic & Devise are just too much.
TXT

  gem.authors = ["Nando Vieira"]
  gem.email = "fnando.vieira@gmail.com"
  gem.homepage = "http://github.com/fnando/simple_auth"

  gem.has_rdoc = false
  gem.files = %w(Rakefile simple_auth.gemspec init.rb VERSION README.markdown) + Dir["{generators,lib,spec,app,config}/**/*"]
end
