# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :require_logged_user, except: :log_in

  def index
    head :ok
  end

  def logged_area
    head :ok
  end

  def log_in
    user_session.record = User.first
    redirect_to return_to(pages_logged_area_path)
  end
end
