# frozen_string_literal: true

class ApiController < ActionController::API
  include SimpleAuth::ActionController::API

  before_action :validate_api_key
  before_action :require_logged_user

  def index
    render json: {message: "hello there"}
  end

  private def authorized_user?
    current_user&.admin?
  end

  private def validate_api_key
    id = request.headers["Authorization"]
    user = User.find_by(id:)

    return render(plain: "401 Unauthorized", status: :unauthorized) unless user

    SimpleAuth::Session.create(
      scope: "user",
      session:,
      record: User.find_by(id:)
    )
  end
end
