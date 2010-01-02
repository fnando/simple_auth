class SimpleAuthGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "simple_auth.rb", "config/initializers/simple_auth.rb"
    end
  end
end
