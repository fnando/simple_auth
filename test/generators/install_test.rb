require "test_helper"

class InstallTest < Rails::Generators::TestCase
  tests SimpleAuth::InstallGenerator
  destination File.expand_path("../../tmp", File.dirname(__FILE__))
  setup :prepare_destination
  setup :run_generator

  test "copies initializer" do
    path = "#{__dir__}/../../tmp/config/initializers/simple_auth.rb"
    assert_file File.expand_path(path)
  end
end
