# frozen_string_literal: true

require "test_helper"

class SessionTest < Minitest::Test
  test "returns nil for missing gid" do
    User.delete_all
    user = User.create!(password: "test", email: "john@example.com")
    session_store = {}

    SimpleAuth::Session.create(
      scope: "user",
      record: user,
      session: session_store
    )

    user.destroy!

    session = SimpleAuth::Session.create(
      scope: "user",
      session: session_store
    )

    assert_nil session.record
  end

  test "returns nil for missing gid (custom error)" do
    not_found_error = Class.new(StandardError)
    SimpleAuth::Session.record_not_found_exceptions << not_found_error

    GlobalID::Locator.use :foo do |gid|
      raise not_found_error, "record not found: #{gid}"
    end

    session = SimpleAuth::Session.create(
      scope: "user",
      session: {user_id: "gid://foo/User/1234"}
    )

    assert_nil session.record
  end
end
