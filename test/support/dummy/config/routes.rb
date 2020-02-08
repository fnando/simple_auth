# frozen_string_literal: true

Rails.application.routes.draw do
  get "/dashboard", to: "dashboard#index"
  get "/admin/dashboard", to: "admin/dashboard#index"
  get "/login", to: "sessions#new"

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
