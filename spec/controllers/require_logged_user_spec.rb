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
    controller do
      require_logged_user :to => "/login"

      def index
        render :text => "Rendered"
      end
    end

    it "should keep other session data" do
      session[:skip_intro] = true
      get :index
      session[:skip_intro].should be_true
    end

    it "should remove record id from session" do
      session[:user_id] = 0
      get :index
      session.should_not have_key(:user)
    end

    it "should remove session id from session" do
      session[:session_id] = "xSQR"
      get :index
      session.should_not have_key(:session_id)
    end

    it "should return the request url" do
      get :index, :some => "param"
      controller.send(:return_to, "/dashboard").should == "/stub_resources?some=param"
    end

    it "should return the default url" do
      controller.send(:return_to, "/dashboard").should == "/dashboard"
    end

    it "should set return to" do
      get :index, :some => "param"
      session[:return_to].should == "/stub_resources?some=param"
    end

    it "should set warning message" do
      get :index
      flash[:alert].should == "You need to be logged"
    end

    it "should redirect when user is not authorized on controller level" do
      session[:user_id] = user.id
      @controller.should_receive(:authorized?).and_return(false)

      get :index
      response.should redirect_to("/login")
    end

    it "should redirect when session is not valid" do
      session[:user_id] = "invalid"

      get :index
      response.should redirect_to("/login")
    end

    context "using hash" do
      controller do
        require_logged_user :to => {:controller => "session", :action => "new"}

        def index
          render :text => "Rendered"
        end
      end

      it "should be redirected" do
        get :index
        response.should redirect_to("/login")
      end
    end

    context "using block" do
      controller do
        require_logged_user :to => proc { login_path }

        def index
          render :text => "Rendered"
        end
      end

      it "should be redirected" do
        get :index
        response.should redirect_to("/login")
      end
    end

    context "using configuration" do
      controller do
        require_logged_user

        def index
          render :text => "Rendered"
        end
      end

      it "should be redirected" do
        SimpleAuth::Config.login_url = "/login"
        get :index
        response.should redirect_to("/login")
      end
    end
  end

  context "when logged" do
    controller do
      require_logged_user

      def index
        render :text => "Rendered"
      end
    end

    it "should render page" do
      session[:user_id] = user.id
      get :index
      response.body.should == "Rendered"
    end
  end
end
