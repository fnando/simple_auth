# Simple Auth

[![Travis-CI](https://travis-ci.org/fnando/simple_auth.svg)](https://travis-ci.org/fnando/simple_auth)
[![Code Climate](https://codeclimate.com/github/fnando/simple_auth/badges/gpa.svg)](https://codeclimate.com/github/fnando/simple_auth)
[![Test Coverage](https://codeclimate.com/github/fnando/simple_auth/badges/coverage.svg)](https://codeclimate.com/github/fnando/simple_auth/coverage)
[![Gem](https://img.shields.io/gem/v/simple_auth.svg)](https://rubygems.org/gems/simple_auth)
[![Gem](https://img.shields.io/gem/dt/simple_auth.svg)](https://rubygems.org/gems/simple_auth)

SimpleAuth is an authentication library to be used when everything else is just
too complicated.

This library only handles session. You have to implement the authentication
strategy as you want (e.g. in-site authentication, OAuth, etc).

## Installation

Just the following line to your Gemfile:

    gem "simple_auth"

Then run `rails generate simple_auth:install` to copy the initializer file.

## Usage

The initializer will install the required helper methods on your controller. So,
let's say you want to support `user` and `admin` authentication. You'll need to
specify the following scope.

```ruby
# config/initializers/simple_auth.rb
SimpleAuth.setup do |config|
  config.scopes = %i[user admin]
  config.login_url = proc { login_path }
  config.logged_url = proc { dashboard_path }

  config.install_helpers!
end
```

Session is valid only when `Controller#authorized_#{scope}?` method returns
`true`, which is the default behavior. You can override these methods with your
own rules; the following example shows how you can authorize all e-mails from
`@example.com` to access the admin dashboard.

```ruby
class Admin::DashboardController < ApplicationController
  private
  def authorized_admin?
    current_user.email.match(/@example.com\z/)
  end
end
```

So, how do you set up a new user session? That's really simple, actually.

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

First thing to notice is that SimpleAuth doesn't care about how you
authenticate. You could easily set up a different authentication strategy, e.g.
API tokens. The important part is assigning the `record:` and `scope:` options.
The `return_to` helper will give you the requested url (before the user logged
in) or the default url.

SimpleAuth uses [GlobalID](https://github.com/rails/globalid) as the session
identifier. This allows using any objects that respond to `#to_gid`, including
namespaced models and POROs.

```ruby
session[:user_id]
#=> gid://myapp/User/1
```

If you need to locate a record using such value, you can do it by calling
`GlobalID::Locator.locate(session[:user_id])`

Finally, only `ActiveRecord::RecordNotFound` errors are trapped by SimpleAuth
(when ActiveRecord is available). If you locator raises a different exception,
add the error class to the list of known exceptions.

```ruby
SimpleAuth::Session.record_not_found_exceptions << CustomNotFoundRecordError
```

### Logging out users

Logging out a user is just as simple; all you have to do is calling the regular
`reset_session`.

### Restricting access

You can restrict access by using 2 macros. Use `redirect_logged_#{scope}` to
avoid rendering a page for logged user.

```ruby
class SignupController < ApplicationController
  before_action :redirect_logged_user
end
```

Use `require_logged_#{scope}` to enforce authenticated access.

```ruby
class DashboardController < ApplicationController
  before_action :require_logged_user
end
```

"So which helpers are defined?", you ask. Just three simple helpers.

```ruby
#{scope}_logged_in?    # e.g. user_logged_in? (available in controller & views)
current_#{scope}       # e.g. current_user    (available in controller & views)
#{scope}_session       # e.g. user_session    (available in controller & views)
```

### Translations

These are the translations you'll need:

```yaml
en:
  simple_auth:
    user:
      need_to_be_logged_in: "You need to be logged"
      not_authorized: "You don't have permission to access this page"
```

If you don't set these translations, a default message will be used.

## Maintainer

* Nando Vieira (<http://nandovieira.com>)

## License:

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
