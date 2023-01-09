# frozen_string_literal: true

require "test_helper"

class AdminTest < ActionDispatch::IntegrationTest
  setup do
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

  test "allows users with admin flag to access page" do
    admin, _ = *create_records

    get "/only/admins"
    assert_equal 404, response.status

    get "/only/admins-by-email"
    assert_equal 404, response.status

    post "/start-session", params: {scope: "admin", id: admin.id}
    assert_equal 200, response.status

    get "/only/admins"
    assert_equal 200, response.status

    get "/only/admins-by-email"
    assert_equal 404, response.status
  end

  test "allows users with admin email to access page" do
    admin, _ = *create_records

    get "/only/admins"
    assert_equal 404, response.status

    get "/only/admins-by-email"
    assert_equal 404, response.status

    post "/start-session", params: {scope: "user", id: admin.id}
    assert_equal 200, response.status

    get "/only/admins"
    assert_equal 404, response.status

    get "/only/admins-by-email"
    assert_equal 200, response.status
  end

  test "rejects users with non admin email" do
    _, user = *create_records

    get "/only/admins"
    assert_equal 404, response.status

    get "/only/admins-by-email"
    assert_equal 404, response.status

    post "/start-session", params: {scope: "user", id: user.id}
    assert_equal 200, response.status

    get "/only/admins"
    assert_equal 404, response.status

    get "/only/admins-by-email"
    assert_equal 404, response.status
  end
end
