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
