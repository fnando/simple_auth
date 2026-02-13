# frozen_string_literal: true

require "test_helper"

class ApiControllerTest < ActionController::TestCase
  setup do
    @routes = Rails.application.routes
    User.delete_all
  end

  def create_records
    admin = User.create!(
      password: "test",
      email: "admin@example.com",
      admin: true
    )
    user = User.create!(
      password: "test",
      email: "john@example.com",
      admin: false
    )

    [admin, user]
  end

  test "renders unauthorized for invalid api keys" do
    get :index

    assert_equal 401, response.status
    assert_equal "401 Unauthorized", response.body
  end

  test "renders unauthorized for unauthorized users" do
    _, user = *create_records
    @request.headers["Authorization"] = user.id.to_s
    get :index

    assert_equal 401, response.status
    assert_equal "401 Unauthorized", response.body
  end

  test "renders page for authorized users" do
    admin, _ = *create_records
    @request.headers["Authorization"] = admin.id.to_s
    get :index

    assert_equal 200, response.status
    assert_equal %[{"message":"hello there"}], response.body
  end
end
