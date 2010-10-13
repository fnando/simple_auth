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

  context "redirecting to requested page" do
    controller do
      require_logged_user :to => "/login"

      def index
        render :text => "Rendered"
      end
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

    it "should redirect when user is not authorized" do
      @controller.should_receive(:logged_in?).and_return(true)
      @controller.should_receive(:authorized?).and_return(false)

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

    before do
      session[:record_id] = user.id
      get :index
    end

    it "should render page" do
      response.body.should == "Rendered"
    end
  end
end
