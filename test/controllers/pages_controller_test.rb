# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionController::TestCase
  setup do
    @routes = Rails.application.routes
    @controller.reset_session

    User.delete_all
  end

  teardown do
    SimpleAuth.config.flash_message_key = :alert
  end

  test "sets flash message while redirecting unlogged user" do
    get :index
    assert_equal "You must be logged in to access this page.", flash[:alert]
  end

  test "sets flash message using custom key" do
    SimpleAuth.config.flash_message_key = :error

    get :index
    assert_equal "You must be logged in to access this page.", flash[:error]
  end

  test "redirects to login url" do
    get :index

    assert_redirected_to login_path
  end

  test "redirects to requested url" do
    get :index
    assert_redirected_to login_path

    get :log_in
    assert_redirected_to controller: :pages, action: :index
  end

  test "redirects to default url" do
    get :log_in
    assert_redirected_to controller: :pages, action: :logged_area
  end
end
