# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :require_logged_user

  def index
    head :ok
  end
end
