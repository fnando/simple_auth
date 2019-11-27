# frozen_string_literal: true

require_relative "../application_controller"

module Admin
  class DashboardController < ::ApplicationController
    before_action :require_logged_admin, only: "index"

    def index
      head :ok
    end

    def log_in_as_user
      user = User.create!(password: "test")
      user_session.record = user
      head :ok
    end

    def log_in_as_admin
      user = User.create!(password: "test")
      admin_session.record = user
      head :ok
    end

    def log_in_with_admin_flag
      user = User.create!(admin: true, password: "test")
      user_session.record = user
      head :ok
    end

    private def authorized?
      current_admin.present? || current_user.admin?
    end
  end
end
