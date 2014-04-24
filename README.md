Simple Auth
===========

SimpleAuth is an authentication library to be used when Authlogic & Devise are just too complicated.

This library only supports in-site authentication and won't implement OpenID, Facebook Connect and like. Rails 3.0+ required.

Installation
------------

Just the following line to your Gemfile:

    gem "simple_auth"

Then run `rails generate simple_auth:install` to copy the initializer file.

Usage
-----

Your user model should have the attribute `password_digest`. The credential field can be anything you want, but SimpleAuth uses `[:email, :login]` by default.

    class CreateUsers < ActiveRecord::Migration
      def change
        create_table :users do |t|
          t.string :email, null: false
          t.string :login, null: false
          t.string :password_digest, null: false

          t.timestamps
        end

        add_index :users, :email, unique: true
        add_index :users, :login, unique: true
        add_index :users, [:email, :login]
      end
    end

In your model, use the `authentication` macro.

    class User < ActiveRecord::Base
      authentication
    end

This will add some callbacks and password validations. It will also inject helper methods like `Model.authenticate`.

Session is valid only when both `Model#authorized?` and `Controller#authorized?` methods return `true`, which is the default behavior. You can override these methods with your own rules:

    class User < ActiveRecord::Base
      authentication

      def authorized?
        deleted_at.nil?
      end
    end

    class Admin::DashboardController < ApplicationController
      private
      def authorized?
        current_user.admin?
      end
    end

After you set up the model, you can go to the controller.

    class SessionsController < ApplicationController
      def new
        @user_session = SimpleAuth::Session.new
      end

      def create
        @user_session = SimpleAuth::Session.new(params[:session])

        if @user_session.save
          redirect_to return_to(dashboard_path)
        else
          flash[:alert] = "Invalid username or password"
          render :new
        end
      end

      def destroy
        current_session.destroy if logged_in?
        redirect_to root_path
      end
    end

The `return_to` helper will give you the requested url (before the user logged in) or the default url.

You can restrict access by using 2 macros:

    class SignupController < ApplicationController
      redirect_logged_user :to => "/"
    end

Here's some usage examples:

    redirect_logged_user :to => proc { login_path }
    redirect_logged_user :to => {:controller => "dashboard"}
    redirect_logged_user :only => [:index], :to => login_path
    redirect_logged_user :except => [:public], :to => login_path

You can skip the `:to` option if you set it globally on your initializer:

    SimpleAuth::Config.logged_url = {:controller => "session", :action => "new"}
    SimpleAuth::Config.logged_url = proc { login_path }

To require a logged user, use the `require_logged_user` macro:

    class DashboardController < ApplicationController
      require_logged_user :to => proc { login_path }
    end

Here's some usage examples:

    require_logged_user :to => proc { login_path }
    require_logged_user :to => {:controller => "session", :action => "new"}
    require_logged_user :only => [:index], :to => login_path
    require_logged_user :except => [:public], :to => login_path

You can skip the `:to` option if you set it globally on your initializer:

    SimpleAuth::Config.login_url = {:controller => "session", :action => "new"}
    SimpleAuth::Config.login_url = proc { login_path }

There are some helpers:

    logged_in?              # controller & views
    current_user            # controller & views
    current_session         # controller & views
    when_logged(&block)     # views
    find_by_credential      # model
    find_by_credential!     # model

If you're having problems to use any helper, include the module `SimpleAuth::Helper` on your `ApplicationHelper`.

    module ApplicationHelper
      include SimpleAuth::Helper
    end

### Translations

These are the translations you'll need:

    en:
      simple_auth:
        sessions:
          need_to_be_logged: "You need to be logged"
          invalid_credentials: "Invalid username or password"

Maintainer
----------

* Nando Vieira (<http://simplesideias.com.br>)

License:
--------

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.