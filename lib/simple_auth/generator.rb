require "rails/generators"

module SimpleAuth
  class InstallGenerator < ::Rails::Generators::Base
    source_root "#{__dir__}/templates/install"

    def copy_initializer_file
      copy_file "initializer.rb", "config/initializers/simple_auth.rb"
    end
  end
end
