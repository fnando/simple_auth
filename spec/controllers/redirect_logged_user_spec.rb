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
      controller ApplicationController do
        redirect_logged_user :to => { :controller => "dashboard" }

        def index
          render :text => "Rendered"
        end
      end

      it "redirects logged users" do
        session[:user_id] = user.id
        get :index

        expect(response.code).to match(/302/)
        expect(response).to redirect_to("/dashboard")
      end
    end

    context "using block" do
      controller ApplicationController do
        redirect_logged_user :to => proc { dashboard_path }

        def index
          render :text => "Rendered"
        end
      end

      it "redirects logged users" do
        session[:user_id] = user.id
        get :index

        expect(response.code).to match(/302/)
        expect(response).to redirect_to("/dashboard")
      end
    end

    context "using configuration" do
      controller ApplicationController do
        redirect_logged_user

        def index
          render :text => "Rendered"
        end
      end

      it "redirects logged users" do
        SimpleAuth::Config.logged_url = proc { dashboard_path }
        session[:user_id] = user.id
        get :index

        expect(response.code).to match(/302/)
        expect(response).to redirect_to("/dashboard")
      end
    end

    context "when unlogged" do
      controller ApplicationController do
        redirect_logged_user :to => { :controller => "dashboard" }

        def index
          render :text => "Rendered"
        end
      end

      it "renders page" do
        session[:user_id] = nil
        get :index

        expect(response.code).to match(/200/)
        expect(response.body).to eq("Rendered")
      end
    end
  end
end
