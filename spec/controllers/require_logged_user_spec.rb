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

  before do
    session[:user_id] = {}
  end

  context "redirecting to requested page" do
    controller ApplicationController do
      require_logged_user :to => "/login"

      def index
        render :text => "Rendered"
      end
    end

    it "should keep other session data" do
      session[:skip_intro] = true
      get :index
      expect(session[:skip_intro]).to be_truthy
    end

    it "should remove record id from session" do
      session[:user_id] = 0
      get :index
      expect(session).not_to have_key(:user)
    end

    it "should remove session id from session" do
      session[:session_id] = "xSQR"
      get :index
      expect(session).not_to have_key(:session_id)
    end

    it "should return the request url" do
      get :index, :some => "param"
      expect(controller.send(:return_to, "/dashboard")).to eq("/anonymous?some=param")
    end

    it "should return the default url" do
      expect(controller.send(:return_to, "/dashboard")).to eq("/dashboard")
    end

    it "should set return to" do
      get :index, :some => "param"
      expect(session[:return_to]).to eq("/anonymous?some=param")
    end

    it "should remove return to from session" do
      get :index, :some => "param"
      controller.send(:return_to, "/dashboard")
      expect(session[:return_to]).to be_nil
    end

    it "should set warning message" do
      get :index
      expect(flash[:alert]).to eq("You need to be logged")
    end

    it "should redirect when user is not authorized on controller level" do
      session[:user_id] = user.id
      expect(@controller).to receive(:authorized?).and_return(false)

      get :index
      expect(response).to redirect_to("/login")
    end

    it "should redirect when session is not valid" do
      session[:user_id] = "invalid"

      get :index
      expect(response).to redirect_to("/login")
    end

    context "using hash" do
      controller ApplicationController do
        require_logged_user :to => {:controller => "session", :action => "new"}

        def index
          render :text => "Rendered"
        end
      end

      it "should be redirected" do
        get :index
        expect(response).to redirect_to("/login")
      end
    end

    context "using block" do
      controller ApplicationController do
        require_logged_user :to => proc { login_path }

        def index
          render :text => "Rendered"
        end
      end

      it "should be redirected" do
        get :index
        expect(response).to redirect_to("/login")
      end
    end

    context "using configuration" do
      controller ApplicationController do
        require_logged_user

        def index
          render :text => "Rendered"
        end
      end

      it "should be redirected" do
        SimpleAuth::Config.login_url = "/login"
        get :index
        expect(response).to redirect_to("/login")
      end
    end
  end

  context "when logged" do
    controller ApplicationController do
      require_logged_user

      def index
        render :text => "Rendered"
      end
    end

    it "should render page" do
      session[:user_id] = user.id
      get :index
      expect(response.body).to eq("Rendered")
    end
  end
end
