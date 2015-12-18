# Migrate from previous versions to v3

Follow these steps:

1. Rename your existing `config/initializers/simple_auth.rb` to `config/initializers/simple_auth.rb.old`.
2. Generate a new initializer with `rails g simple_auth:install`. Update `config/initializers/simple_auth.rb` with your settings (check `simple_auth.rb.old`).
3. Remove `config/initializers/simple_auth.rb.old`.
4. Remove `authentication` from your model (e.g. `User`).
5. Replace all calls from old version as the list below:
    - Controllers: `require_logged_user` becomes `before_action :require_logged_user`.
    - Controllers: `redirect_logged_user` becomes `before_action :redirect_logged_user`.
    - Controllers & Views: `logged_in?` becomes `user_logged_in?`.
    - Controllers: `authorized?` becomes `authorized_user?`.
    - Controllers: `current_session.destroy` becomes `reset_session`.
6. On your sessions controller, replace the call to `SimpleAuth::Session.new` to something like this:
```ruby
class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by_email(params[:email])

    if @user.try(:authenticate, params[:password])
      SimpleAuth::Session.create(scope: "user", session: session, record: @user)
      redirect_to return_to(dashboard_path)
    else
      flash[:alert] = "Invalid username or password"
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
```

If you have any issue, just [open a ticket](https://github.com/fnando/simple_auth/issues/new).
