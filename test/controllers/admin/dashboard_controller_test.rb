# frozen_string_literal: true

require "test_helper"

class AdminDashboardControllerTest < ActionController::TestCase
  tests Admin::DashboardController

  setup do
    @routes = Rails.application.routes
    @controller.reset_session
  end

  test "authorizes logged admin" do
    get :log_in_as_admin
    get :index

    assert_response :success
  end

  test "authorizes logged user with admin flag" do
    get :log_in_as_admin
    get :index

    assert_response :success
  end

  test "denies user" do
    get :log_in_as_user
    get :index

    assert_redirected_to login_path
  end
end
