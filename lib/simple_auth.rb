module SimpleAuth
  require "rails/railtie"
  require "active_support/concern"

  require "simple_auth/version"
  require "simple_auth/config"
  require "simple_auth/railtie"
  require "simple_auth/action_controller"
  require "simple_auth/action_controller/require_login_action"
  require "simple_auth/session"
  require "simple_auth/generator"

  def self.setup
    yield config
  end

  def self.config
    @config ||= Config.new
  end

  setup do |config|
    config.scopes = %i[user]
    config.login_url = -> { login_path }
    config.logged_url = -> { dashboard_path }
  end
end
