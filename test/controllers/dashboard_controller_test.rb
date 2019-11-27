# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionController::TestCase
  setup do
    @routes = Rails.application.routes
    @controller.reset_session

    User.delete_all
    User.create!(password: "test", email: "john@example.com")
  end

  test "redirects unlogged user to login path" do
    get :index
    assert_redirected_to login_path
  end

  test "sets flash message while redirecting unlogged user" do
    get :index
    assert_equal "You don't have permission to access this page.", flash[:alert]
  end

  test "renders page for logged user" do
    get :log_in
    get :index

    assert_response :success
  end

  test "redirects logged user" do
    get :log_in
    get :not_logged

    assert_redirected_to dashboard_path
  end

  test "renders page for unlogged user" do
    get :not_logged
    assert_response :success
  end

  test "redirects unauthorized user" do
    User.create!(password: "test", email: "john@example.org")
    get :log_in
    get :index

    assert_redirected_to login_path
  end

  test "sets flash message while redirecting unauthorized user" do
    User.create!(password: "test", email: "john@example.org")
    get :log_in
    get :index

    assert_equal "You don't have permission to access this page.", flash[:alert]
  end
end
