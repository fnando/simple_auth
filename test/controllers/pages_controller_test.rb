# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionController::TestCase
  setup do
    @routes = Rails.application.routes
    @controller.reset_session

    User.delete_all
    User.create!(password: "test", email: "john@example.com")
  end

  test "sets flash message while redirecting unlogged user" do
    get :index
    assert_equal "You must be logged in to access this page.", flash[:alert]
  end
end
