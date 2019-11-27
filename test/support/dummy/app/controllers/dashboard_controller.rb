# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :require_logged_user, except: %w[log_in not_logged]
  before_action :redirect_logged_user, only: "not_logged"

  def index
    head :ok
  end

  def log_in
    user_session.record = User.last!
    head :ok
  end

  def not_logged
    head :ok
  end

  private def authorized_user?
    current_user.try(:email).to_s.match(/@example.com\z/)
  end
end
