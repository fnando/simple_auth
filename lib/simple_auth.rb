# frozen_string_literal: true

module SimpleAuth
  require "rails/railtie"
  require "global_id/railtie"
  require "active_support/concern"
  require "action_dispatch/routing/mapper"

  require "simple_auth/version"
  require "simple_auth/config"
  require "simple_auth/railtie"
  require "simple_auth/action_controller"
  require "simple_auth/routing_mapper"
  require "simple_auth/action_controller/require_login_action"
  require "simple_auth/session"
  require "simple_auth/generator"

  ::ActionDispatch::Routing::Mapper.prepend SimpleAuth::RoutingMapper

  def self.setup
    yield config
  end

  def self.config
    @config ||= Config.new
  end

  setup do |config|
    config.flash_message_key = :alert
    config.scopes = %i[user]
    config.login_url = -> { login_path }
    config.logged_url = -> { dashboard_path }
  end
end
