module SimpleAuth
  class Railtie < Rails::Railtie
    generators do
      require "simple_auth/generator"
    end
  end
end
