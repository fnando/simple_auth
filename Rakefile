require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

desc "Run specs against all gemfiles"
task "spec:all" do
  %w[
    Gemfile
    gemfiles/rails_3_1.gemfile
    gemfiles/rails_3_2.gemfile
    gemfiles/rails_4_0.gemfile
    gemfiles/rails_4_1.gemfile
  ].each do |gemfile|
    puts "\n=> Running with Gemfile: #{gemfile}"
    system "BUNDLE_GEMFILE=#{gemfile} bundle exec rspec"
    exit 1 unless $?.success?
  end
end
