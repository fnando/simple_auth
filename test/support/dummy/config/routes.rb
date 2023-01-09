# frozen_string_literal: true

Rails.application.routes.draw do
  get "/dashboard", to: "dashboard#index"
  get "/admin/dashboard", to: "admin/dashboard#index"
  get "/login", to: "sessions#new"

  post "/start-session", to: "sessions#create_session"
  post "/terminate-session", to: "sessions#terminate_session"

  authenticate :admin, ->(u) { u.admin? } do
    get "/only/admins", to: ->(_env) { [200, {}, ["OK"]] }
  end

  authenticate :user, ->(u) { u.email == "admin@example.com" } do
    get "only/admins-by-email", to: ->(_env) { [200, {}, ["OK"]] }
  end

  controller :dashboard do
    get :log_in
    get :not_logged
  end

  controller :pages do
    get :index
    get :log_in
    get :logged_area, as: "pages_logged_area"
  end

  namespace :admin do
    controller :dashboard do
      get :index
      get :log_in_as_admin
      get :log_in_as_user
      get :log_in_with_admin_flag
    end
  end
end
