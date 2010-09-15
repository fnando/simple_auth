require "rails/generators/base"

module SimpleAuth
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.dirname(__FILE__) + "/../../templates"

    def copy_initializer_file
      copy_file "initializer.rb", "config/initializers/simple_auth.rb"
    end
  end
end
