# Add routes
ActionController::Routing::Routes.add_route "/:controller/:action/:id"
ActionController::Routing::Routes.add_named_route :login, "/login", :controller => "session", :action => "new"
ActionController::Routing::Routes.add_named_route :dashboard, "/dashboard", :controller => "dashboard", :action => "index"

class SampleController < ActionController::Base
end

class SessionController < ActionController::Base
  redirect_logged_user :to => {:controller => "dashboard"}

  def new
    @user_session = SimpleAuth::Session.new
  end

  def create
    @user_session = SimpleAuth::Session.new(params[:session])

    if @user_session.save
      redirect_to session.delete(:return_to) || dashboard_path
    else
      flash[:alert] = "Invalid login/password."
      render :new
    end
  end
end

class DashboardController < ActionController::Base
  def index
  end
end
