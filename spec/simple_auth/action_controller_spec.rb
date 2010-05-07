require File.dirname(__FILE__) + "/../spec_helper"

describe DashboardController, :type => :controller do
  before do
    @user = User.create(
      :login => "johndoe",
      :email => "john@doe.com",
      :password => "test",
      :password_confirmation => "test"
    )
  end

  describe "require_logged_user" do
    context "unlogged user" do
      before do
        if ENV["TARGET"] != "rails3"
          DashboardController.filter_chain.pop if DashboardController.filter_chain.count > 1
        end
      end

      context "return to" do
        before do
          DashboardController.require_logged_user :to => "/login"
        end

        it "should set return to" do
          get :index
          session[:return_to].should == "/dashboard"
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
      end

      it "should be redirected [hash]" do
        DashboardController.require_logged_user :to => {:controller => "session", :action => "new"}

        get :index
        
        if ENV["TARGET"] == "rails3"
          response.should redirect_to("/login")
        else
          response.should redirect_to("/session/new")
        end
      end

      it "should be redirected [block]" do
        DashboardController.require_logged_user :to => proc { login_path }

        get :index
        response.should redirect_to("/login")
      end

      it "should be redirected [string]" do
        DashboardController.require_logged_user :to => "/login"

        get :index
        response.should redirect_to("/login")
      end
    end

    context "logged user" do
      before do
        session[:record_id] = @user.id
        get :index
      end

      it "should render page" do
        response.should render_template(:index)
      end
    end
  end
end

describe SessionController, :type => :controller do
  before do
    @user = User.create(
      :login => "johndoe",
      :email => "john@doe.com",
      :password => "test",
      :password_confirmation => "test"
    )
  end
  
  describe "redirect_logged_users" do
    context "unlogged user" do
      before do
        get :new
      end
  
      it "should render page" do
        response.should render_template(:new)
      end
    end
  
    context "logged user" do
      before do
        session[:record_id] = @user.id
        get :new
      end
  
      it "should be redirected" do
        response.should redirect_to("/dashboard")
      end
    end
  end
end