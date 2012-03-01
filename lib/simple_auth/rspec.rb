module SimpleAuth
  module RSpec
    # A simple helper to stub current session options.
    #
    #   simple_auth(:user => User.first) # the most common case
    #   simple_auth(:authorized => false)
    #   simple_auth(:session => mock("current_session", :valid? => false))
    #
    # This is how you set it up:
    #
    #   # spec/spec_helper.rb
    #   require "simple_auth/rspec"
    #   RSpec.configure {|c| c.include SimpleAuth::RSpec, :type => :controller}
    #
    def simple_auth(options = {})
      options.reverse_merge!({
        :session => mock("current_session").as_null_object,
        :authorized => true,
        :user => mock("current_user").as_null_object
      })

      controller.stub({
        :current_user => options[:user],
        :authorized? => options[:authorized],
        :current_session => options[:session]
      })
    end
  end
end
