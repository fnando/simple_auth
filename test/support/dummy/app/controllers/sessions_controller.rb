# frozen_string_literal: true

class SessionsController < ApplicationController
  def create_session
    session["#{params[:scope]}_id"] = User.find(params[:id]).to_gid.to_s
    render plain: "", status: 200
  end

  def terminate_session
    reset_session
    render plain: "", status: 200
  end
end
