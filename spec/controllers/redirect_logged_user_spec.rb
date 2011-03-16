require "spec_helper"

describe ApplicationController do
  let(:user) {
    User.create(
      :login => "johndoe",
      :email => "john@doe.com",
      :password => "test",
      :password_confirmation => "test"
    )
  }

  context "redirecting logged users" do
    context "using hash" do
      controller do
        redirect_logged_user :to => { :controller => "dashboard" }

        def index
          render :text => "Rendered"
        end
      end

      it "should redirect logged users" do
        session[:user_id] = user.id
        get :index

        response.code.should match(/302/)
        response.should redirect_to("/dashboard")
      end
    end

    context "using block" do
      controller do
        redirect_logged_user :to => proc { dashboard_path }

        def index
          render :text => "Rendered"
        end
      end

      it "should redirect logged users" do
        session[:user_id] = user.id
        get :index

        response.code.should match(/302/)
        response.should redirect_to("/dashboard")
      end
    end

    context "using configuration" do
      controller do
        redirect_logged_user

        def index
          render :text => "Rendered"
        end
      end

      it "should redirect logged users" do
        SimpleAuth::Config.logged_url = proc { dashboard_path }
        session[:user_id] = user.id
        get :index

        response.code.should match(/302/)
        response.should redirect_to("/dashboard")
      end
    end

    context "when unlogged" do
      controller do
        redirect_logged_user :to => { :controller => "dashboard" }

        def index
          render :text => "Rendered"
        end
      end

      it "should render page" do
        session[:user_id] = nil
        get :index

        response.code.should match(/200/)
        response.body.should == "Rendered"
      end
    end
  end
end
